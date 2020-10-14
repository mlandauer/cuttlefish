# frozen_string_literal: true

class AdminsController < ApplicationController
  def index
    result = api_query
    @data = result.data
    @admins = @data.admins

    @admin = Admin.new
  end

  def destroy
    result = api_query id: params[:id]
    if result.data.remove_admin
      admin = result.data.remove_admin.admin
      flash[:notice] = "#{admin.display_name} removed"
    else
      flash[:alert] = "Couldn't remove admin."
    end
    redirect_to admins_url
  end
end
