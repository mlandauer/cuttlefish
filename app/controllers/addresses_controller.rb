class AddressesController < ApplicationController
  def from
    @deliveries = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
      result = Cuttlefish::ApiClient.query(
        Cuttlefish::ApiClient::ADDRESSES_FROM_QUERY,
        variables: { from: params[:id], limit: pager.per_page, offset: pager.offset },
        current_admin: current_admin
      )

      @from = params[:id]
      @stats = result.data.emails.statistics

      pager.replace(result.data.emails.nodes)
      pager.total_entries = result.data.emails.total_count
    end
  end

  def to
    # Avoid information leak by not revealing whether this email address has been seen before
    address = Address.find_or_initialize_by(text: params[:id])
    d = policy_scope(Delivery).to_address(address)
    @stats = Delivery.stats(d)
    @deliveries = d.includes(:open_events, :click_events, :email => :app).order("deliveries.created_at DESC").paginate(page: params[:page])

    @to = params[:id]
    @deny_list = address.deny_list(current_admin.team)    
  end
end
