# Insert a tracking image at the bottom of the html email
class Filters::AddOpenTracking < Filters::Tracking
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  attr_accessor :delivery_id, :enabled

  def initialize(delivery)
    @delivery_id = delivery.id
    @enabled = delivery.open_tracking_enabled?
    super(delivery)
  end

  def filter_html(input)
    if enabled
      delivery.set_open_tracked!
      # TODO Add image tag in a place to keep html valid (not just the end of the document)
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
      hash: HashId.hash(delivery_id),
      format: :gif
    )
  end
end
