class ClientsController < ApplicationController
  def index
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::CLIENT_QUERY,
      variables: { appId: params[:app_id] },
      current_admin: current_admin
    )
    @client_counts = result.data.emails.statistics.user_agent_family_counts
    @apps = result.data.apps
    @app = @apps.find{|a| a.id == params[:app_id]} if params[:app_id]
  end
end
