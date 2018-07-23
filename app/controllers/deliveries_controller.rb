require "graphql/client"
require "graphql/client/http"

class DeliveriesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  def index
    @deliveries = policy_scope(Delivery)

    if params[:search]
      @search = params[:search]
      @deliveries = @deliveries.joins(:address).where("addresses.text" => @search)
    else
      @status = params[:status]
      if params[:app_id]
        @app = App.find(params[:app_id])
        @deliveries = @deliveries.where(app_id: @app.id)
        @deliveries = @deliveries.joins(:email).where("emails.app_id" => @app.id)
      end
      @deliveries = @deliveries.where(status: @status) if @status
    end

    @deliveries = @deliveries.includes(:delivery_links, :postfix_log_lines, :email, :address).order("deliveries.created_at DESC").page(params[:page])
  end


  def show
    result = Cuttlefish::ApiClient::CLIENT.query(
      Cuttlefish::ApiClient::EMAIL_QUERY,
      variables: {id: params[:id]},
      context: { api_key: current_admin.api_key }
    )
    @delivery = result.data.email
  end
end
