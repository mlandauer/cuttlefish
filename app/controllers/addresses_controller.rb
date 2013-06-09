class AddressesController < ApplicationController
  def show
    @address = Address.find(params[:id])
    @emails = @address.emails.order("created_at DESC").paginate(page: params[:page])
  end

  def from
    @address = Address.find(params[:id])
    @emails = @address.emails_sent.order("created_at DESC").paginate(page: params[:page])
  end

  def to
    @address = Address.find(params[:id])
    @emails = @address.emails_received.order("created_at DESC").paginate(page: params[:page])
  end
end
