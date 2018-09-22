class TeamsController < ApplicationController
  after_action :verify_authorized, except: :index

  def index
    # TODO Check for errors
    result = api_query :teams
    @teams = result.data.teams
    @cuttlefish_app = App.cuttlefish
    @admin = Admin.new
  end

  def invite
    authorize :team
    team = Team.create!
    # TODO Add some error checking
    Admin.invite!({email: params[:admin][:email], team_id: team.id}, current_admin)
    flash[:notice] = "Invited #{params[:admin][:email]} to a new team"
    redirect_to teams_path
  end
end
