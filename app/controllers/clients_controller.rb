class ClientsController < ApplicationController
  def index
    result = api_query app_id: params[:app_id]
    @client_counts = result.data.emails.statistics.user_agent_family_counts
    @apps = result.data.apps
    @app = @apps.find{|a| a.id == params[:app_id]} if params[:app_id]
  end
end
