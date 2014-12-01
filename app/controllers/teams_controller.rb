class TeamsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :team
    @teams = Team.all
  end
end
