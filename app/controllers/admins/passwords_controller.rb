# frozen_string_literal: true

module Admins
  class PasswordsController < DeviseController
    layout "login"

    prepend_before_action :require_no_authentication
    # Render the #edit only if coming from a reset password email link
    append_before_action :assert_reset_token_passed, only: :edit

    # GET /resource/password/new
    def new
      @admin = AdminForm.new
    end

    # POST /resource/password
    def create
      api_query email: params[:admin][:email], reset_url: edit_admin_password_url

      flash[:notice] = "If your email address exists in our database, " \
                       "you will receive a password recovery link at your email address in a few minutes."
      redirect_to new_session_url(:admin)
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    def edit
      @admin = AdminForm.new
      @admin.reset_password_token = params[:reset_password_token]
    end

    # PUT /resource/password
    def update
      @admin = Admin.reset_password_by_token(
        reset_password_token: params[:admin][:reset_password_token],
        password: params[:admin][:password]
      )

      if @admin.errors.empty?
        flash[:notice] = if @admin.active_for_authentication?
                           "Your password has been changed successfully. You are now signed in."
                         else
                           "Your password has been changed successfully."
                         end
        sign_in(:admin, @admin)
        redirect_to dash_url
      else
        render :edit
      end
    end

    protected

    # Check if a reset_password_token is provided in the request
    def assert_reset_token_passed
      return unless params[:reset_password_token].blank?

      flash[:notice] = "You can't access this page without coming from a password reset email. " \
                       "If you do come from a password reset email, please make sure you used the full URL provided."
      redirect_to new_admin_session_url
    end
  end
end
