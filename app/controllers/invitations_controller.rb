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

    @admin = Admin.invite_to_team!(
      email: params[:admin][:email],
      inviting_admin: current_admin,
      accept_url: accept_admin_invitation_url
    )

    if @admin.errors.empty?
      set_flash_message :notice, :send_instructions, email: @admin.email
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
