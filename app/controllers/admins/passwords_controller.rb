# frozen_string_literal: true

module Admins
  class PasswordsController < DeviseController
    layout "login"

    prepend_before_action :require_no_authentication
    # Render the #edit only if coming from a reset password email link
    append_before_action :assert_reset_token_passed, only: :edit

    # GET /resource/password/new
    def new
      self.resource = AdminForm.new
    end

    # POST /resource/password
    def create
      self.resource = Admin.send_reset_password_instructions(
        { email: params[:admin][:email] },
        { reset_url: edit_admin_password_url }
      )

      # We're being paranoid and not leaking any information in error messages
      resource.errors.clear

      flash[:notice] = "If your email address exists in our database, " \
                       "you will receive a password recovery link at your email address in a few minutes."
      redirect_to new_session_url(:admin)
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    def edit
      self.resource = Admin.new
      set_minimum_password_length
      resource.reset_password_token = params[:reset_password_token]
    end

    # PUT /resource/password
    def update
      self.resource = Admin.reset_password_by_token(resource_params)
      yield resource if block_given?

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        if Devise.sign_in_after_reset_password
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, flash_message)
          resource.after_database_authentication
          sign_in(:admin, resource)
        else
          set_flash_message!(:notice, :updated_not_active)
        end
        respond_with resource, location: after_resetting_password_path_for(resource)
      else
        set_minimum_password_length
        respond_with resource
      end
    end

    protected

    def after_resetting_password_path_for(resource)
      Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(:admin)
    end

    # Check if a reset_password_token is provided in the request
    def assert_reset_token_passed
      return unless params[:reset_password_token].blank?

      set_flash_message(:alert, :no_token)
      redirect_to new_session_path(:admin)
    end

    # Check if proper Lockable module methods are present & unlock strategy
    # allows to unlock resource on password reset
    def unlockable?(resource)
      resource.respond_to?(:unlock_access!) &&
        resource.respond_to?(:unlock_strategy_enabled?) &&
        resource.unlock_strategy_enabled?(:email)
    end

    def translation_scope
      "devise.passwords"
    end
  end
end
