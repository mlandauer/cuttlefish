class EmailsController < ApplicationController

  def index
    if params[:from]
      @email_address = EmailAddress.find_by_address(params[:from])
      @emails = @email_address.emails_sent.order("created_at DESC").paginate(:page => params[:page])
    elsif params[:to]
      @email_address = EmailAddress.find_by_address(params[:to])
      @emails = @email_address.emails_received.order("created_at DESC").paginate(:page => params[:page])
    else
      @emails = Email.order("created_at DESC").paginate(:page => params[:page])
    end
  end

  def show
    @email = Email.find(params[:id])
  end

end
