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

    # Make the invited user part of the same team as the person doing the inviting
    self.resource = Admin.invite!(
      invite_params.merge(team_id: current_admin.team_id),
      current_admin
    )

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, email: resource.email
      respond_with resource, location: admins_path
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  def update
    authorize :invitation
    super
  end
end
