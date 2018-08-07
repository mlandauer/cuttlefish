class DocumentationController < ApplicationController
  def index
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::DOCUMENTATION_QUERY,
      variables: {},
      current_admin: current_admin
    )
    @apps = result.data.apps
    @active_app = @apps.first
  end
end
