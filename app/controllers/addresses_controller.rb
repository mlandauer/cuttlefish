class AddressesController < ApplicationController
  def from
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_sent(current_admin.team).includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end

  def to
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_received(current_admin.team).includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end
end
