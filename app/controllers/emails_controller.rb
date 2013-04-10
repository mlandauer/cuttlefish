class EmailsController < ApplicationController

  def index
    if params[:delivered] == "true"
      @delivered = true
    elsif params[:delivered] == "false"
      @delivered = false
    end

    if params[:from]
      @address = Address.find_by_text(params[:from])
      @emails = @address.emails_sent.order("created_at DESC").paginate(:page => params[:page])
    elsif params[:to]
      @address = Address.find_by_text(params[:to])
      @emails = @address.emails_received.order("created_at DESC").paginate(:page => params[:page])
    else
      if @delivered.nil?
        @emails = Email.order("created_at DESC").paginate(:page => params[:page])
      else
        @emails = Email.where(delivered: @delivered).order("created_at DESC").paginate(:page => params[:page])
      end
    end
  end

  def show
    @email = Email.find(params[:id])
  end

end
