class Admins::RegistrationsController < Devise::RegistrationsController
  layout "login", except: [:edit, :update]
  before_filter :check_first_user, only: [:new, :create]

  private

  def check_first_user
    redirect_to new_admin_session_url if Admin.first
  end
end