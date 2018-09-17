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
    @deliveries = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
      result = Cuttlefish::ApiClient.query(
        Cuttlefish::ApiClient::ADDRESSES_TO_QUERY,
        variables: { to: params[:id], limit: pager.per_page, offset: pager.offset },
        current_admin: current_admin
      )

      @to = params[:id]
      @stats = result.data.emails.statistics
      @deny_list = result.data.blocked_address

      pager.replace(result.data.emails.nodes)
      pager.total_entries = result.data.emails.total_count
    end
  end
end
