class Admins::InvitationsController < Devise::InvitationsController
  layout "login", only: [:edit, :update]

  private

  # Make the invited user part of the same team as the person doing the inviting
  def invite_resource
    resource_class.invite!(invite_params.merge(team_id: current_inviter.team_id), current_inviter)
  end
end
