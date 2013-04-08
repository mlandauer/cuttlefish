class AddressesController < ApplicationController
  def index
    @addresses = Address.order("text").paginate(:page => params[:page])
  end
end
