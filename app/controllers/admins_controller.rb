class AdminsController < ApplicationController
  def index
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::ADMINS_QUERY,
      variables: { },
      current_admin: current_admin
    )
    @admins = result.data.admins

    @admin = Admin.new
  end
end
