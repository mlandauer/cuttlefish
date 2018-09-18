class DeliveriesController < ApplicationController
  def index
    if params[:search]
      redirect_to to_address_url(id: params[:search])
    else
      @status = params[:status]
      @deliveries = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
        result = Cuttlefish::ApiClient.query(
          Cuttlefish::ApiClient::EMAILS_QUERY,
          variables: { status: params[:status], appId: params[:app_id], limit: pager.per_page, offset: pager.offset },
          current_admin: current_admin
        )
        pager.replace(result.data.emails.nodes)
        pager.total_entries = result.data.emails.total_count

        @apps = result.data.apps
        @app = @apps.find{|a| a.id == params[:app_id]} if params[:app_id]
      end
    end
  end


  def show
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::EMAIL_QUERY,
      variables: { id: params[:id] },
      current_admin: current_admin
    )
    @delivery = result.data.email
    @configuration = result.data.configuration
    raise ActiveRecord::RecordNotFound if @delivery.nil?
  end
end
