# frozen_string_literal: true

module Admins
  class RegistrationsController < ApplicationController
    layout "login", except: %i[edit update]

    # GET /resource/sign_up
    def new
      redirect_to new_admin_session_url if Admin.first

      @admin = AdminForm.new
    end

    # POST /resource
    def create
      result = if params[:admin]
                 api_query(
                   name: params[:admin][:name],
                   email: params[:admin][:email],
                   password: params[:admin][:password]
                 )
               else
                 api_query(
                   email: "",
                   password: ""
                 )
               end
      @data = result.data

      if @data.register_site_admin.errors.empty?
        flash[:notice] = "Welcome! You have signed up successfully."
        # Automatically log us in
        session[:jwt_token] = @data.register_site_admin.token
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
      # Get the current admin id from the session
      payload, _header = JWT.decode(session[:jwt_token], nil, false)
      api_query id: payload["admin_id"]

      # And logout
      session[:jwt_token] = nil
      flash[:notice] = "Bye! Your account has been successfully cancelled. We hope to see you again soon."

      redirect_to root_url
    end
  end
end
