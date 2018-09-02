class DeliveriesController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @status = params[:status]
    @search = params[:search]
    if params[:app_id]
      @app = App.find(params[:app_id])
      authorize @app, :show?
      @deliveries = @app.deliveries
    else
      @deliveries = policy_scope(Delivery)
    end

    @deliveries = @deliveries.where(status: @status) if @status
    @deliveries = @deliveries.joins(:email).where("emails.app_id" => @app.id) if @app
    @deliveries = @deliveries.joins(:address).where("addresses.text" => @search) if @search

    @deliveries = @deliveries.includes(:delivery_links, :postfix_log_lines, :email, :address).order("deliveries.created_at DESC").page(params[:page])
  end

  def show
    @delivery = Delivery.find(params[:id])
    authorize @delivery
  end
end
