class Admins::RegistrationsController < Devise::RegistrationsController
  layout "login"

  def new
    if Admin.first.nil?
      super
    else
      redirect_to new_admin_session_url
    end
  end
end