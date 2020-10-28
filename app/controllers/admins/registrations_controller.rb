# frozen_string_literal: true

module Admins
  class RegistrationsController < Devise::RegistrationsController
    after_action :verify_authorized, except: :edit

    layout "login", except: %i[edit update]
    before_action :check_first_user, only: %i[new create]

    def edit
      result = api_query
      @data = result.data
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
      devise_parameter_sanitizer.sanitize(:sign_up)
                                .merge(team_id: team.id, site_admin: true)
    end
  end
end
