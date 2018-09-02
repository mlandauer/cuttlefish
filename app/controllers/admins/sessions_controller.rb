class Admins::SessionsController < Devise::SessionsController
  layout "login"
  before_filter :check_first_user, only: :new

  private

  def check_first_user
    redirect_to new_admin_registration_url if Admin.first.nil?
  end
end