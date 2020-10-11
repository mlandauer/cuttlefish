# frozen_string_literal: true

module Admins
  class SessionsController < Devise::SessionsController
    layout "login"
    before_action :check_first_user, only: :new

    # POST /resource/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    private

    def check_first_user
      redirect_to new_admin_registration_url if Admin.first.nil?
    end
  end
end
