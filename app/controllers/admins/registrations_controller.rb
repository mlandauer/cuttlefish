# frozen_string_literal: true

module Admins
  class RegistrationsController < DeviseController
    after_action :verify_authorized, except: %i[new edit update]

    layout "login", except: %i[edit update]
    before_action :check_first_user, only: %i[new create]

    prepend_before_action :require_no_authentication, only: %i[new create]
    prepend_before_action :authenticate_scope!, only: %i[edit update destroy]
    prepend_before_action :set_minimum_password_length, only: %i[new edit]

    # GET /resource/sign_up
    def new
      @admin = AdminForm.new
    end

    # POST /resource
    def create
      authorize :registration

      # TODO: Put these in a transaction
      team = Team.create!
      @admin = Admin.new(
        name: params[:admin]&.[](:name),
        email: params[:admin]&.[](:email),
        password: params[:admin]&.[](:password),
        team_id: team.id,
        site_admin: true
      )
      @admin.save

      if @admin.persisted?
        flash[:notice] = "Welcome! You have signed up successfully."
        sign_in(:admin, @admin)
        redirect_to dash_url
      else
        clean_up_passwords resource
        set_minimum_password_length

        render :new
      end
    end

    # GET /resource/edit
    def edit
      result = api_query
      @data = result.data

      @admin = AdminForm.new(email: @data.viewer.email, name: @data.viewer.name)

      render :edit
    end

    # PUT /resource
    # We need to use a copy of the resource because we don't want to change
    # the current user in place.
    def update
      # TODO: Doing this for the tests currently. Get rid of this
      result = if params[:admin]
                 api_query(
                   email: params[:admin][:email],
                   name: params[:admin][:name],
                   password: params[:admin][:password],
                   current_password: params[:admin][:current_password]
                 )
               else
                 api_query(
                   email: "",
                   name: "",
                   current_password: ""
                 )
               end
      @data = result.data

      if @data.update_admin.errors.empty?
        flash[:notice] = "Your account has been updated successfully."
        bypass_sign_in Admin.find(current_admin.id), scope: :admin

        redirect_to dash_url
      else
        @admin = AdminForm.new(email: params[:admin]&.[](:email), name: params[:admin]&.[](:name))
        copy_graphql_errors(@data.update_admin, @admin, ["attributes"])

        # TODO: Not ideal we're doing a second query here. Would be great to avoid this
        result = api_query :update_error, {}
        @data = result.data

        render :edit
      end
    end

    # DELETE /resource
    def destroy
      authorize :registration

      resource.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :destroyed
      yield resource if block_given?
      respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
    end

    protected

    # Authenticates the current scope and gets the current resource from the session.
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!", force: true)
      self.resource = send(:"current_#{resource_name}")
    end

    def translation_scope
      "devise.registrations"
    end

    private

    def check_first_user
      redirect_to new_admin_session_url if Admin.first
    end
  end
end
