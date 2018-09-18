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
    destroy_deny_list = DestroyDenyList.call(current_admin: current_admin, id: params[:id])
    if destroy_deny_list.result
      flash[:notice] = "#{destroy_deny_list.result.address.text} removed from deny list"
    else
      flash[:alert] = "Couldn't remove from deny list. You probably don't have the necessary permissions."
    end
    redirect_back(fallback_location: deny_lists_url)
  end
end
