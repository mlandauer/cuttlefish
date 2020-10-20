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

    result = api_query email: params[:admin][:email], accept_url: accept_admin_invitation_url
    @data = result.data

    if @data.invite_admin_to_team.errors.empty?
      set_flash_message :notice, :send_instructions, email: params[:admin][:email]
      redirect_to admins_url
    else
      @admin = Admin.new(email: params[:admin][:email])
      copy_graphql_errors(result.data.invite_admin_to_team, @admin, ["attributes"])

      result = api_query :create_error, {}
      @data = result.data
      @admins = @data.admins
      render "admins/index"
    end
  end

  # PUT /resource/invitation
  def update
    authorize :invitation

    self.resource = Admin.accept_invitation!(
      invitation_token: params[:admin][:invitation_token],
      name: params[:admin][:name],
      password: params[:admin][:password]
    )

    if resource.errors.empty?
      set_flash_message :notice, :updated
      sign_in(:admin, resource)
      redirect_to dash_url
    else
      resource.invitation_token = params[:admin][:invitation_token]
      respond_with_navigational(resource) { render :edit }
    end
  end
end
