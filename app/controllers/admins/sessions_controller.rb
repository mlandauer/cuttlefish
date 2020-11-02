# frozen_string_literal: true

module Admins
  class SessionsController < ApplicationController
    layout "login"
    before_action :check_first_user, only: :new

    # GET /resource/sign_in
    def new
      @admin = AdminForm.new(email: params[:admin]&.[](:email))
    end

    # POST /resource/sign_in
    def create
      result = api_query email: params[:admin][:email],
                         password: params[:admin][:password]
      if result.data.login_admin.admin
        # Store the returned token in the session
        # TODO: Empty this when we logout
        session[:jwt_token] = result.data.login_admin.token
        admin = Admin.find(result.data.login_admin.admin.id)
        flash[:notice] = "Signed in successfully."
        sign_in :admin, admin

        redirect_to dash_url
      else
        flash[:alert] = result.data.login_admin.errors.map(&:message).join(", ")
        @admin = AdminForm.new(email: params[:admin][:email])
        render :new
      end
    end

    # DELETE /resource/sign_out
    def destroy
      signed_out = sign_out
      flash[:notice] = "Signed out successfully." if signed_out

      redirect_to root_url
    end

    private

    def check_first_user
      # TODO: Get this info from the API instead
      redirect_to new_admin_registration_url if Admin.first.nil?
    end
  end
end
