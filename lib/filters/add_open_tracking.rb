# frozen_string_literal: true

# Insert a tracking image at the bottom of the html email
module Filters
  class AddOpenTracking < Filters::Tracking
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers

    attr_accessor :delivery_id, :enabled

    def initialize(options)
      @delivery_id = options[:delivery_id]
      @enabled = options[:enabled]
      super(options)
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
