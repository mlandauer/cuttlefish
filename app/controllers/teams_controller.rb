class TeamsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :team
    @teams = Team.all
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
