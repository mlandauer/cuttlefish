# frozen_string_literal: true

module Admins
  class SessionsController < Devise::SessionsController
    layout "login"
    before_action :check_first_user, only: :new

    def create
      result = api_query email: params[:admin][:email],
                         password: params[:admin][:password]
      if result.data.login_admin.admin
        # Store the returned token in the session
        # TODO: Empty this when we logout
        session[:jwt_token] = result.data.login_admin.token
        admin = Admin.find(result.data.login_admin.admin.id)
        set_flash_message!(:notice, :signed_in)
        sign_in :admin, admin
        respond_with admin, location: after_sign_in_path_for(admin)
      else
        flash[:alert] = result.data.login_admin.errors.map(&:message).join(", ")
        @admin = AdminForm.new(
          email: params[:admin][:email],
          password: params[:admin][:password]
        )
        render :new
      end
    end

    private

    def check_first_user
      redirect_to new_admin_registration_url if Admin.first.nil?
    end
  end
end
