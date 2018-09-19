class DenyListsController < ApplicationController
  def index
    @deny_lists = WillPaginate::Collection.create(params[:page] || 1, WillPaginate.per_page) do |pager|
      result = Cuttlefish::ApiClient.query(
        Cuttlefish::ApiClient::DENY_LISTS_INDEX_QUERY,
        variables: { limit: pager.per_page, offset: pager.offset },
        current_admin: current_admin
      )
      pager.replace(result.data.blocked_addresses.nodes)
      pager.total_entries = result.data.blocked_addresses.total_count
    end
  end

  def destroy
    result = Cuttlefish::ApiClient.query(
      Cuttlefish::ApiClient::REMOVE_BLOCKED_ADDRESS_MUTATION,
      variables: { id: params[:id] },
      current_admin: current_admin
    )
    blocked_address = result.data.remove_blocked_address.blocked_address
    if blocked_address
      flash[:notice] = "#{blocked_address.address} removed from deny list"
    else
      flash[:alert] = "Couldn't remove from deny list. You probably don't have the necessary permissions."
    end
    redirect_back(fallback_location: deny_lists_url)
  end
end
