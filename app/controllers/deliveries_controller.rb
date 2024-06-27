# frozen_string_literal: true

class DeliveriesController < ApplicationController
  def index
    if params[:search]
      redirect_to to_address_url(id: params[:search])
    else
      @status = params[:status]
      @key = params[:key]
      @deliveries = WillPaginate::Collection.create(
        params[:page] || 1,
        WillPaginate.per_page
      ) do |pager|
        result = api_query status: params[:status], app_id: params[:app_id], meta_key: @key,
                           limit: pager.per_page, offset: pager.offset
        pager.replace(result.data.emails.nodes)
        pager.total_entries = result.data.emails.total_count

        @data = result.data
        @apps = @data.apps
        @app = @apps.find { |a| a.id == params[:app_id] } if params[:app_id]
      end
    end
  end

  def show
    result = api_query id: params[:id]
    @data = result.data
    @delivery = @data.email
    @configuration = @data.configuration
  end

  def html
    result = api_query id: params[:id]
    @data = result.data
    # TODO: Inline images
    @html = @data.email.content.html
    render html: @html.html_safe, layout: false
  end
end
