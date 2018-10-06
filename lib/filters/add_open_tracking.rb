# frozen_string_literal: true

# Insert a tracking image at the bottom of the html email
module Filters
  class AddOpenTracking < Filters::Mail
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers

    attr_accessor :delivery_id, :enabled,
                  :tracking_domain, :using_custom_tracking_domain

    def initialize(delivery_id:, enabled:,
                   tracking_domain:, using_custom_tracking_domain:)
      @delivery_id = delivery_id
      @enabled = enabled
      @tracking_domain = tracking_domain
      @using_custom_tracking_domain = using_custom_tracking_domain
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

    # Hostname to use for the open tracking image or rewritten link
    def host
      Rails.env.development? ? "localhost:3000" : tracking_domain
    end

    # Whether to use ssl for the open tracking image or rewritten link
    def protocol
      using_custom_tracking_domain || Rails.env.development? ? "http" : "https"
    end
  end
end
