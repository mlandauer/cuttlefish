# frozen_string_literal: true

module Admins
  class PasswordsController < ApplicationController
    layout "login"

    # Render the #edit only if coming from a reset password email link
    append_before_action :assert_reset_token_passed, only: :edit

    # GET /resource/password/new
    def new
      @admin = AdminForm.new
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    def edit
      @admin = AdminForm.new(reset_password_token: params[:reset_password_token])
    end

    # POST /resource/password
    def create
      api_query email: params[:admin][:email], reset_url: edit_admin_password_url

      flash[:notice] = "If your email address exists in our database, " \
                       "you will receive a password recovery link at your email address in a few minutes."
      redirect_to new_session_url(:admin)
    end

    # PUT /resource/password
    def update
      result = api_query token: params[:admin][:reset_password_token], password: params[:admin][:password]
      @data = result.data

      if @data.reset_password_by_token.errors.empty?
        flash[:notice] = "Your password has been changed successfully."

        # Automatically log us in
        session[:jwt_token] = @data.reset_password_by_token.token
        redirect_to dash_url
      else
        @admin = AdminForm.new(reset_password_token: params[:admin][:reset_password_token])
        copy_graphql_errors(@data.reset_password_by_token, @admin, ["attributes"])

        render :edit
      end
    end

    protected

    # Check if a reset_password_token is provided in the request
    def assert_reset_token_passed
      return if params[:reset_password_token].present?

      flash[:notice] = "You can't access this page without coming from a password reset email. " \
                       "If you do come from a password reset email, please make sure you used the full URL provided."
      redirect_to new_admin_session_url
    end
  end
end
