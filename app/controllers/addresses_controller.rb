class AddressesController < ApplicationController
  def index
    @addresses = Address.order("text").paginate(:page => params[:page])
  end

  def show
    @address = Address.find(params[:id])
    @emails = @address.emails.order("created_at DESC").paginate(:page => params[:page])
  end
end
