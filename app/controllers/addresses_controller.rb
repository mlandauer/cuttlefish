class AddressesController < ApplicationController
  def index
    @status = params[:status]

    if @status == "from"
      @addresses = Address.all_sent_email.order("text").paginate(:page => params[:page])
    elsif @status == "to"
      @addresses = Address.all_received_email.order("text").paginate(:page => params[:page])
    else
      @addresses = Address.order("text").paginate(:page => params[:page])
    end
  end

  def show
    @address = Address.find(params[:id])
    @emails = @address.emails.order("created_at DESC").paginate(:page => params[:page])
  end
end
