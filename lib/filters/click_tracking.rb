# frozen_string_literal: true

module Filters
  class ClickTracking < Filters::Mail
    include Rails.application.routes.url_helpers

    attr_accessor :delivery_id, :enabled, :tracking_domain_info

    def initialize(delivery_id:, enabled:, tracking_domain_info:)
      super()
      @delivery_id = delivery_id
      @enabled = enabled
      @tracking_domain_info = tracking_domain_info
    end

    def rewrite_url(url)
      link = Link.find_or_create_by(url: url)
      delivery_link = DeliveryLink.find_or_create_by(
        delivery_id: delivery_id,
        link_id: link.id
      )
      tracking_click_url(
        host: tracking_domain_info[:domain],
        protocol: tracking_domain_info[:protocol],
        delivery_link_id: delivery_link.id,
        hash: HashId.hash("#{delivery_link.id}-#{url}"),
        url: url
      )
    end

    def filter_html(input)
      if enabled
        TransformHtml.new(input).rewrite_links { |url| rewrite_url(url) }
      else
        input
      end
    end
  end
end
