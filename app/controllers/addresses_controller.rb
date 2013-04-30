class AddressesController < ApplicationController
  def index
    @status = params[:status]

    if @status == "from"
      query = Address.all_sent_email
    elsif @status == "to"
      query = Address.all_received_email
    else
      query = Address.all
    end
    @addresses = query.order("text").paginate(:page => params[:page])
  end

  def show
    @address = Address.find(params[:id])
    @emails = @address.emails.order("created_at DESC").paginate(:page => params[:page])
  end
end
