class DeliveriesController < ApplicationController
  def index
    @deliveries = Delivery.all.includes(:open_events, :link_events, :postfix_log_lines, :email, :address).order("created_at DESC").page(params[:page])
  end
end
