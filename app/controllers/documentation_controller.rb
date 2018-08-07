class DocumentationController < ApplicationController
  def index
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::DOCUMENTATION_QUERY,
      variables: {},
      current_admin: current_admin
    )
    # TODO: Move check of error inside above method
    raise result.errors.messages["data"].join(", ") unless result.errors.empty?

    @apps = result.data.apps.nodes
    @active_app = @apps.first
  end
end
