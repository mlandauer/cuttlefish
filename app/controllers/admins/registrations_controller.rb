# frozen_string_literal: true

module Admins
  class RegistrationsController < DeviseController
    after_action :verify_authorized, except: %i[new create edit update]

    layout "login", except: %i[edit update]

    prepend_before_action :require_no_authentication, only: %i[new create]
    prepend_before_action :set_minimum_password_length, only: %i[new edit]

    # GET /resource/sign_up
    def new
      redirect_to new_admin_session_url if Admin.first

      @admin = AdminForm.new
    end

    # POST /resource
    def create
      result = api_query(
        name: params[:admin]&.[](:name),
        email: params[:admin]&.[](:email),
        password: params[:admin]&.[](:password)
      )
      @data = result.data

      if @data.register_site_admin.errors.empty?
        flash[:notice] = "Welcome! You have signed up successfully."
        sign_in(:admin, Admin.find(@data.register_site_admin.admin.id))
        redirect_to dash_url
      else
        @admin = AdminForm.new(
          name: params[:admin]&.[](:name),
          email: params[:admin]&.[](:email)
        )
        copy_graphql_errors(@data.register_site_admin, @admin, ["attributes"])

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

      current_admin.destroy
      sign_out
      flash[:notice] = "Bye! Your account has been successfully cancelled. We hope to see you again soon."

      redirect_to root_url
    end
  end
end
