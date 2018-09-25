class DenyListsController < ApplicationController
  def index
    @deny_lists = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
      result = api_query limit: pager.per_page, offset: pager.offset
      pager.replace(result.data.blocked_addresses.nodes)
      pager.total_entries = result.data.blocked_addresses.total_count
    end
  end

  def destroy
    result = api_query id: params[:id]
    blocked_address = result.data.remove_blocked_address.blocked_address
    if blocked_address
      flash[:notice] = "#{blocked_address.address} removed from deny list"
    else
      flash[:alert] = "Couldn't remove from deny list. You probably don't have the necessary permissions."
    end
    redirect_back(fallback_location: deny_lists_url)
  end
end
