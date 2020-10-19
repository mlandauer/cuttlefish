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

    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if Devise.allow_insecure_sign_in_after_accept
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)
        respond_with resource, location: after_accept_path_for(resource)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, location: new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource) { render :edit }
    end
  end

  private

  def accept_resource
    resource_class.accept_invitation!(update_resource_params)
  end

  def update_resource_params
    devise_parameter_sanitizer.sanitize(:accept_invitation)
  end
end
