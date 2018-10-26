# frozen_string_literal: true

class AdminsController < ApplicationController
  def index
    result = api_query
    @admins = result.data.admins

    @admin = Admin.new
  end

  def destroy
    result = api_query id: params[:id]
    if result.data.remove_admin
      admin = result.data.remove_admin.admin
      flash[:notice] = "#{admin.display_name} removed"
    else
      result.data.errors.details.each do |_path, details|
        details.each do |detail|
          case detail["extensions"]["type"]
          when "NOT_AUTHORIZED"
            # TODO: Put the message in the error too
            raise Pundit::NotAuthorizedError
          when "NOT_FOUND"
            # TODO: Put the message in the error too
            raise ActiveRecord::RecordNotFound
          end
        end
      end
      flash[:alert] = "Couldn't remove admin."
    end
    redirect_to admins_url
  end
end
