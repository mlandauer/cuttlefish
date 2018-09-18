class DenyListsController < ApplicationController
  after_action :verify_authorized, except: :index

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
    deny_list = DenyList.find(params[:id])
    authorize deny_list
    deny_list.destroy
    redirect_back(fallback_location: deny_lists_url)
  end
end
