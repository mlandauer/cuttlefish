class AddressesController < ApplicationController
  def from
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_sent.includes(:open_events, :link_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end

  def to
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_received.includes(:open_events, :link_events, :email => :app).order("created_at DESC").paginate(page: params[:page])
  end
end
