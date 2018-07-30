class DeliveriesController < ApplicationController
  def index
    if params[:search]
      @deliveries = policy_scope(Delivery)
      @apps = policy_scope(App)

      @search = params[:search]
      @deliveries = @deliveries.joins(:address).where("addresses.text" => @search)
      @deliveries = @deliveries.includes(:delivery_links, :postfix_log_lines, :email, :address).order("deliveries.created_at DESC").page(params[:page])
    else
      @status = params[:status]
      @deliveries = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
        result = Cuttlefish::ApiClient::CLIENT.query(
          Cuttlefish::ApiClient::EMAILS_QUERY,
          variables: { status: params[:status], appId: params[:app_id], first: pager.per_page, skip: pager.offset },
          context: { api_key: current_admin.api_key }
        )
        # TODO: Show an error if graphql returns one
        pager.replace(result.data.emails.nodes)
        pager.total_entries = result.data.emails.total_count

        @apps = result.data.apps.nodes
        @app = @apps.find{|a| a.id == params[:app_id]} if params[:app_id]
      end
    end
  end


  def show
    result = Cuttlefish::ApiClient::CLIENT.query(
      Cuttlefish::ApiClient::EMAIL_QUERY,
      variables: {id: params[:id]},
      context: { api_key: current_admin.api_key }
    )
    raise result.errors.messages["data"].join(", ") unless result.errors.empty?
    @delivery = result.data.email
    @configuration = result.data.configuration
  end
end
