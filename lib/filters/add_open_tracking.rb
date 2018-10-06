# frozen_string_literal: true

# Insert a tracking image at the bottom of the html email
module Filters
  class AddOpenTracking < Filters::Mail
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers

    attr_accessor :delivery_id, :enabled
    attr_reader :host, :protocol

    def initialize(delivery_id:, enabled:,
                   tracking_domain:, using_custom_tracking_domain:)
      @delivery_id = delivery_id
      @enabled = enabled
      @host = Rails.env.development? ? "localhost:3000" : tracking_domain
      @protocol = using_custom_tracking_domain || Rails.env.development? ? "http" : "https"
    end

    def filter_html(input)
      if enabled
        # TODO: Add image tag in a place to keep html valid (not just the
        # end of the document)
        input + image_tag(url, alt: nil)
      else
        input
      end
    end

    # The url for the tracking image
    def url
      tracking_open_url(
        host: host,
        protocol: protocol,
        delivery_id: delivery_id,
        hash: HashId.hash(delivery_id.to_s),
        format: :gif
      )
    end
  end
end
