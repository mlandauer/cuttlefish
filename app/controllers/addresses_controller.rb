class AddressesController < ApplicationController
  def show
    @address = Address.find(params[:id])
    @emails = @address.emails.order("created_at DESC").paginate(page: params[:page])
  end
end
