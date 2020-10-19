# frozen_string_literal: true

class InvitationsController < Devise::InvitationsController
  after_action :verify_authorized, except: %i[new edit]

  layout "login", only: %i[edit update]

  # TODO: Remove this action (and associated route) as it's currently unused
  def new
    result = api_query
    @data = result.data
    super
  end

  def create
    authorize :invitation

    # Make the invited user part of the same team as the person doing the inviting
    invited_admin = Admin.invite!(
      { email: params[:admin][:email], team_id: current_admin.team_id },
      current_admin,
      accept_url: accept_admin_invitation_url
    )

    if invited_admin.errors.empty?
      set_flash_message :notice, :send_instructions, email: invited_admin.email
      redirect_to admins_url
    else
      result = api_query
      @data = result.data
      @admins = @data.admins
      render "admins/index"
    end
  end

  def update
    authorize :invitation
    super
  end
end
