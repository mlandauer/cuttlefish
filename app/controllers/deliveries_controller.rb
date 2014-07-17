class DeliveriesController < ApplicationController
  def index
    @status = params[:status]
    @search = params[:search]
    @app = App.find(params[:app_id]) if params[:app_id]

    @deliveries = @status.nil? ? Delivery.all : Delivery.where(status: @status)
    @deliveries = @deliveries.joins(:email).where("emails.app_id" => @app.id) if @app
    @deliveries = @deliveries.joins(:address).where("addresses.text" => @search) if @search

    @deliveries = @deliveries.includes(:open_events, :click_events, :postfix_log_lines, :email, :address).order("deliveries.created_at DESC").page(params[:page])
  end

  def show
    @delivery = Delivery.find(params[:id])
  end
end
