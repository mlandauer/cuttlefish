# frozen_string_literal: true

class Admins::RegistrationsController < Devise::RegistrationsController
  after_action :verify_authorized

  layout "login", except: [:edit, :update]
  before_action :check_first_user, only: [:new, :create]

  def edit
    authorize :registration
    super
  end

  def update
    authorize :registration
    super
  end

  def destroy
    authorize :registration
    super
  end

  def new
    authorize :registration
    super
  end

  def create
    authorize :registration
    super
  end

  private

  def check_first_user
    redirect_to new_admin_session_url if Admin.first
  end

  def sign_up_params
    team = Team.create!
    devise_parameter_sanitizer.sanitize(:sign_up).merge(team_id: team.id, site_admin: true)
  end
end
