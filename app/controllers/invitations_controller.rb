# frozen_string_literal: true

class InvitationsController < Devise::InvitationsController
  after_action :verify_authorized, except: :edit

  layout "login", only: %i[edit update]

  def create
    authorize :invitation
    super
  end

  def update
    authorize :invitation
    super
  end

  private

  # Make the invited user part of the same team as the person doing the inviting
  def invite_resource
    resource_class.invite!(
      invite_params.merge(team_id: current_inviter.team_id),
      current_inviter
    )
  end

  def after_invite_path_for(_resource)
    admins_path
  end
end
