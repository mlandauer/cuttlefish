# frozen_string_literal: true

module Admins
  class RegistrationsController < DeviseController
    after_action :verify_authorized, except: %i[edit update]

    layout "login", except: %i[edit update]
    before_action :check_first_user, only: %i[new create]

    prepend_before_action :require_no_authentication, only: %i[new create]
    prepend_before_action :authenticate_scope!, only: %i[edit update destroy]
    prepend_before_action :set_minimum_password_length, only: %i[new edit]

    # GET /resource/sign_up
    def new
      authorize :registration

      self.resource = Admin.new
      yield resource if block_given?
      respond_with resource
    end

    # POST /resource
    def create
      authorize :registration

      self.resource = Admin.new(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
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

    # Signs in a user on sign up. You can overwrite this method in your own
    # RegistrationsController.
    def sign_up(resource_name, resource)
      sign_in(resource_name, resource)
    end

    # The path used after sign up. You need to overwrite this method
    # in your own RegistrationsController.
    def after_sign_up_path_for(resource)
      after_sign_in_path_for(resource) if is_navigational_format?
    end

    # The path used after sign up for inactive accounts. You need to overwrite
    # this method in your own RegistrationsController.
    def after_inactive_sign_up_path_for(resource)
      scope = Devise::Mapping.find_scope!(resource)
      router_name = Devise.mappings[scope].router_name
      context = router_name ? send(router_name) : self
      context.respond_to?(:root_path) ? context.root_path : "/"
    end

    # Authenticates the current scope and gets the current resource from the session.
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!", force: true)
      self.resource = send(:"current_#{resource_name}")
    end

    def account_update_params
      devise_parameter_sanitizer.sanitize(:account_update)
    end

    def translation_scope
      "devise.registrations"
    end

    private

    def check_first_user
      redirect_to new_admin_session_url if Admin.first
    end

    def sign_up_params
      team = Team.create!
      devise_parameter_sanitizer.sanitize(:sign_up)
                                .merge(team_id: team.id, site_admin: true)
    end
  end
end
