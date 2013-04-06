class EmailsController < ApplicationController

  def index
    @emails = Email.order("created_at DESC").paginate(:page => params[:page])
  end

  def show
    @email = Email.find(params[:id])
  end

end
