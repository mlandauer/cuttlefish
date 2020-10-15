# frozen_string_literal: true

class InvitationsController < Devise::InvitationsController
  after_action :verify_authorized, except: %i[new edit]

  layout "login", only: %i[edit update]

  # TODO: Remove this action (and associated route) as it's currently unused
  # except when the create action fails
  def new
    result = api_query
    @data = result.data
    super
  end

  def create
    authorize :invitation
    result = api_query
    @data = result.data

    self.resource = invite_resource

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, email: resource.email
      respond_with resource, location: after_invite_path_for(current_inviter)
    else
      respond_with_navigational(resource) { render :new }
    end
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
