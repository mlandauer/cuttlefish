class Admins::SessionsController < Devise::SessionsController
  def new
    if Admin.first.nil?
      redirect_to new_admin_registration_url
    else
      super
    end
  end
end