class AddressesController < ApplicationController
  def from
    # Avoid information leak by not revealing whether this email address has been seen before
    @address = Address.find_or_initialize_by(text: params[:id])
    d = policy_scope(Delivery).joins(:email).where(emails: {from_address_id: @address.id})
    @stats = Delivery.stats(d)
    @deliveries = d.includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end

  def to
    # Avoid information leak by not revealing whether this email address has been seen before
    @address = Address.find_or_initialize_by(text: params[:id])
    d = policy_scope(Delivery).where(address_id: @address.id)
    @stats = Delivery.stats(d)
    @deliveries = d.includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])
  end
end
