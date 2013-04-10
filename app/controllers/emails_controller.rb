class EmailsController < ApplicationController

  def index
    @status = params[:status]

    if @status.nil?
      @emails = Email.order("created_at DESC").paginate(:page => params[:page])
    else
      @emails = Email.where(delivery_status: @status).order("created_at DESC").paginate(:page => params[:page])
    end
  end

  def show
    @email = Email.find(params[:id])
  end

end
