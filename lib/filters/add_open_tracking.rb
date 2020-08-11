# frozen_string_literal: true

# Insert a tracking image at the bottom of the html email
module Filters
  class AddOpenTracking < Filters::Mail
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers

    attr_accessor :delivery_id, :enabled, :tracking_domain_info

    def initialize(delivery_id:, enabled:, tracking_domain_info:)
      super()
      @delivery_id = delivery_id
      @enabled = enabled
      @tracking_domain_info = tracking_domain_info
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
        host: tracking_domain_info[:domain],
        protocol: tracking_domain_info[:protocol],
        delivery_id: delivery_id,
        hash: HashId.hash(delivery_id.to_s),
        format: :gif
      )
    end
  end
end
