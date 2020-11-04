# frozen_string_literal: true

class TeamsController < ApplicationController
  def index
    # TODO: Check for errors
    result = api_query
    @data = result.data
    @teams = @data.teams
    @cuttlefish_app = @data.cuttlefish_app
    @admin = OpenStruct.new(email: nil)
  end

  def invite
    result = api_query(
      email: params[:admin][:email],
      accept_url: accept_admin_invitation_url
    )
    @data = result.data

    # TODO: Add some error checking
    flash[:notice] = "Invited #{params[:admin][:email]} to a new team"
    redirect_to teams_path
  end
end
