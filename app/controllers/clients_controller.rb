# frozen_string_literal: true

class ClientsController < ApplicationController
  def index
    result = api_query app_id: params[:app_id]
    @data = result.data
    @client_counts = @data.emails.statistics.user_agent_family_counts
    @apps = @data.apps
    @app = @apps.find { |a| a.id == params[:app_id] } if params[:app_id]
  end
end
