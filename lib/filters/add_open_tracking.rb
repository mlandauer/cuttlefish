# Insert a tracking image at the bottom of the html email
class Filters::AddOpenTracking < Filters::Tracking
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def filter_html(input)
    if @delivery.open_tracking_enabled?
      @delivery.set_open_tracked!
      input + image_tag(url(@delivery), alt: nil)
    else
      input
    end
  end

  # The url for the tracking image
  def url(delivery)
    tracking_open_url(
      host: host(delivery),
      protocol: protocol(delivery),
      delivery_id: delivery.id,
      hash: HashId.hash(delivery.id),
      format: :gif
    )
  end
end
