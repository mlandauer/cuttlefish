class AdminsController < ApplicationController
  def index
    result = api_query
    @admins = result.data.admins

    @admin = Admin.new
  end

  def destroy
    result = api_query id: params[:id]
    admin = result.data.remove_admin.admin
    if admin
      flash[:notice] = "#{admin.display_name} removed"
    else
      flash[:alert] = "Couldn't remove admin. You probably don't have the necessary permissions."
    end
    redirect_to admins_url
  end
end
