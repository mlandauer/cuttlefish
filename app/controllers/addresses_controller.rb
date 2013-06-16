class AddressesController < ApplicationController
  # TODO: Remove this action
  def show
    @address = Address.find(params[:id])
    @emails = @address.emails.order("created_at DESC").paginate(page: params[:page])
  end

  def from
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_sent.order("created_at DESC").paginate(page: params[:page])
  end

  def to
    @address = Address.find(params[:id])
    @deliveries = @address.deliveries_received.order("created_at DESC").paginate(page: params[:page])
  end
end
