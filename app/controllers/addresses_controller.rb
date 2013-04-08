class AddressesController < ApplicationController
  def index
    @addresses = Address.order("text").paginate(:page => params[:page])
  end

  def show
    @address = Address.find(params[:id])
  end
end
