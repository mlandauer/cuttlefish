# frozen_string_literal: true

module Filters
  class ClickTracking < Filters::Mail
    include Rails.application.routes.url_helpers

    attr_accessor :delivery_id, :enabled
    attr_reader :host, :protocol

    def initialize(delivery_id:, enabled:,
                   tracking_domain:, using_custom_tracking_domain:)
      @delivery_id = delivery_id
      @enabled = enabled
      @host = Rails.env.development? ? "localhost:3000" : tracking_domain
      @protocol = if using_custom_tracking_domain || Rails.env.development?
                    "http"
                  else
                    "https"
                  end
    end

    def rewrite_url(url)
      link = Link.find_or_create_by(url: url)
      delivery_link = DeliveryLink.find_or_create_by(
        delivery_id: delivery_id,
        link_id: link.id
      )
      tracking_click_url(
        host: host,
        protocol: protocol,
        delivery_link_id: delivery_link.id,
        hash: HashId.hash("#{delivery_link.id}-#{url}"),
        url: url
      )
    end

    def filter_html(input)
      if enabled
        doc = Nokogiri::HTML(input)
        doc.search("a[href]").each do |a|
          a["href"] = rewrite_url(a["href"])
        end
        doc.to_s
      else
        input
      end
    end
  end
end
