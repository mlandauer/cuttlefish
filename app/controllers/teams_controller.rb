# frozen_string_literal: true

class TeamsController < ApplicationController
  # TODO: Revert 68fa5c3b8896e8ac853650ebf24eb8793dc2911f as soon as we don't
  # need this here anymore
  after_action :verify_authorized, except: :index

  def index
    # TODO: Check for errors
    result = api_query
    @data = result.data
    @teams = @data.teams
    @cuttlefish_app = @data.cuttlefish_app
    @admin = OpenStruct.new(email: nil)
  end

  def invite
    authorize :team
    team = Team.create!
    # TODO: Add some error checking
    Admin.invite!(
      { email: params[:admin][:email], team_id: team.id },
      current_admin,
      accept_url: accept_admin_invitation_url
    )
    flash[:notice] = "Invited #{params[:admin][:email]} to a new team"
    redirect_to teams_path
  end
end
