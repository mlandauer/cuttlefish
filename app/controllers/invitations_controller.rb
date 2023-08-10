# frozen_string_literal: true

class InvitationsController < ApplicationController
  layout "login", only: %i[edit update]

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    # Sign us out
    session[:jwt_token] = nil
    @admin = AdminForm.new(invitation_token: params[:invitation_token])
    render :edit
  end

  def create
    result = api_query email: params[:admin][:email], accept_url: accept_admin_invitation_url
    @data = result.data

    if @data.invite_admin_to_team.errors.empty?
      flash[:notice] = "An invitation email has been sent to #{params[:admin][:email]}."
      redirect_to admins_url
    else
      @admin = AdminForm.new(email: params[:admin][:email])
      copy_graphql_errors(result.data.invite_admin_to_team, @admin, ["attributes"])

      result = api_query :create_error, {}
      @data = result.data
      @admins = @data.admins
      render "admins/index"
    end
  end

  # PUT /resource/invitation
  def update
    result = api_query(
      name: params[:admin][:name],
      password: params[:admin][:password],
      token: params[:admin][:invitation_token]
    )
    @data = result.data

    if @data.accept_admin_invitation.errors.empty?
      flash[:notice] = "Your password was set successfully. You are now signed in."
      session[:jwt_token] = @data.accept_admin_invitation.token
      redirect_to dash_url
    else
      @admin = AdminForm.new(
        name: params[:admin][:name],
        invitation_token: params[:admin][:invitation_token]
      )
      copy_graphql_errors(result.data.accept_admin_invitation, @admin, ["attributes"])
      render :edit
    end
  end
end
