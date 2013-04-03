class EmailsController < ApplicationController

  def index
    # Only show the most recent 10 for the time being
    @emails = Email.order("created_at DESC").limit(10)
  end

  def show
    @email = Email.find(params[:id])
  end

end
