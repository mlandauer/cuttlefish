class AddressesController < ApplicationController
  def from
    # Avoid information leak by not revealing whether this email address has been seen before
    @address = Address.find_or_initialize_by(text: params[:id])
    d = policy_scope(Delivery).from_address(@address)
    @stats = Delivery.stats(d)
    @deliveries = d.includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end

  def to
    # Avoid information leak by not revealing whether this email address has been seen before
    @address = Address.find_or_initialize_by(text: params[:id])
    d = policy_scope(Delivery).to_address(@address)
    @stats = Delivery.stats(d)
    @deliveries = d.includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end
end
