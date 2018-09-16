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

  def destroy
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::REMOVE_ADMIN_MUTATION,
      variables: { id: params[:id] },
      current_admin: current_admin
    )
    admin = result.data.remove_admin.admin
    if admin
      flash[:notice] = "#{admin.display_name} removed"
    else
      flash[:alert] = "Couldn't remove admin. You probably don't have the necessary permissions."
    end
    redirect_to admins_url
  end
end
