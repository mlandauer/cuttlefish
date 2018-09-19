class AddressesController < ApplicationController
  def from
    @deliveries = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
      result = api_query :addresses_from_query,
        from: params[:id], limit: pager.per_page, offset: pager.offset

      @from = params[:id]
      @stats = result.data.emails.statistics

      pager.replace(result.data.emails.nodes)
      pager.total_entries = result.data.emails.total_count
    end
  end

  def to
    @deliveries = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
      result = api_query :addresses_to_query,
        to: params[:id], limit: pager.per_page, offset: pager.offset

      @to = params[:id]
      @stats = result.data.emails.statistics
      @deny_list = result.data.blocked_address

      pager.replace(result.data.emails.nodes)
      pager.total_entries = result.data.emails.total_count
    end
  end
end
