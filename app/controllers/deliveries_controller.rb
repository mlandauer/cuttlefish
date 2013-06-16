class DeliveriesController < ApplicationController
  def index
    @status = params[:status]
    @deliveries = @status.nil? ? Delivery.all : Delivery.where(status: @status)
    @deliveries = @deliveries.includes(:open_events, :link_events, :postfix_log_lines, :email, :address).order("created_at DESC").page(params[:page])
  end

  def show
    @delivery = Delivery.find(params[:id])
  end
end
