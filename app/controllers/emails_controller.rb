class EmailsController < ApplicationController

  def index
    if params[:from]
      @address = Address.find_by_address(params[:from])
      @emails = @address.emails_sent.order("created_at DESC").paginate(:page => params[:page])
    elsif params[:to]
      @address = Address.find_by_address(params[:to])
      @emails = @address.emails_received.order("created_at DESC").paginate(:page => params[:page])
    else
      @emails = Email.order("created_at DESC").paginate(:page => params[:page])
    end
  end

  def show
    @email = Email.find(params[:id])
  end

end
