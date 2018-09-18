class ClientsController < ApplicationController
  def index
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::CLIENT_QUERY,
      variables: { },
      current_admin: current_admin
    )
    @client_counts = result.data.emails.statistics.user_agent_family_counts
  end
end
