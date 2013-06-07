class EmailsController < ApplicationController

  def index
    @status = params[:status]

    @emails = @status.nil? ? Email.all : Email.where(status: @status)
    @emails = @emails.includes(:to_addresses, :open_events, :link_events).order("created_at DESC").paginate(page: params[:page])
  end

  def show
    @email = Email.find(params[:id])
  end

end
