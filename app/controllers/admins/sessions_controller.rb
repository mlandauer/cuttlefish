# frozen_string_literal: true

module Admins
  class SessionsController < ApplicationController
    layout "login"

    # GET /resource/sign_in
    def new
      result = api_query
      @data = result.data

      redirect_to new_admin_registration_url if @data.configuration.fresh_install
      @admin = AdminForm.new(email: params[:admin]&.[](:email))
    end

    # POST /resource/sign_in
    def create
      result = api_query email: params[:admin][:email],
                         password: params[:admin][:password]
      if result.data.login_admin.admin
        # Store the returned token in the session
        session[:jwt_token] = result.data.login_admin.token
        flash[:notice] = "Signed in successfully."

        redirect_to dash_url
      else
        flash[:alert] = result.data.login_admin.errors.map(&:message).join(", ")
        @admin = AdminForm.new(email: params[:admin][:email])
        render :new
      end
    end

    # DELETE /resource/sign_out
    def destroy
      session[:jwt_token] = nil
      flash[:notice] = "Signed out successfully."

      redirect_to root_url
    end
  end
end
