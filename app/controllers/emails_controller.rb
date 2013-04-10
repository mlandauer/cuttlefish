class EmailsController < ApplicationController

  def index
    if params[:delivered] == "true"
      @delivered = true
    elsif params[:delivered] == "false"
      @delivered = false
    end

    if @delivered.nil?
      @emails = Email.order("created_at DESC").paginate(:page => params[:page])
    else
      @emails = Email.where(delivered: @delivered).order("created_at DESC").paginate(:page => params[:page])
    end
  end

  def show
    @email = Email.find(params[:id])
  end

end
