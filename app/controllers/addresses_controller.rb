class AddressesController < ApplicationController
  def from
    # Avoid information leak by not revealing whether this email address has been seen before
    @address = Address.find_or_initialize_by(text: params[:id])
    @stats = Delivery.stats(@address.deliveries_sent(current_admin.team))
    @deliveries = @address.deliveries_sent(current_admin.team).includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end

  def to
    # Avoid information leak by not revealing whether this email address has been seen before
    @address = Address.find_or_initialize_by(text: params[:id])
    @stats = Delivery.stats(@address.deliveries_received(current_admin.team))
    @deliveries = @address.deliveries_received(current_admin.team).includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end
end
