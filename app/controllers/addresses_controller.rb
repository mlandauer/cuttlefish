# frozen_string_literal: true

class AddressesController < ApplicationController
  def from
    @deliveries = WillPaginate::Collection.create(
      params[:page] || 1,
      WillPaginate.per_page
    ) do |pager|
      result = api_query from: params[:id],
                         limit: pager.per_page,
                         offset: pager.offset

      @from = params[:id]
      @stats = result.data.emails.statistics

      pager.replace(result.data.emails.nodes)
      pager.total_entries = result.data.emails.total_count
    end
  end

  def to
    @deliveries = WillPaginate::Collection.create(
      params[:page] || 1,
      WillPaginate.per_page
    ) do |pager|
      result = api_query to: params[:id],
                         limit: pager.per_page,
                         offset: pager.offset

      @to = params[:id]
      @stats = result.data.emails.statistics
      @deny_lists = result.data.blocked_addresses.nodes

      pager.replace(result.data.emails.nodes)
      pager.total_entries = result.data.emails.total_count
    end
  end
end
