class AddressesController < ApplicationController
  def from
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_sent.order("created_at DESC").paginate(page: params[:page])
  end

  def to
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_received.order("created_at DESC").paginate(page: params[:page])
  end
end
