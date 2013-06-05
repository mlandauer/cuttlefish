# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < TrackingFilter
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def apply_html?
    open_tracking_enabled?
  end

  def process_html(input)
    delivery.set_open_tracked!
    input + image_tag(url, :alt => nil)
  end

  # The url for the tracking image
  def url
    tracking_open_url(
      host: host, 
      protocol: protocol,
      :delivery_id => id,
      :hash => open_tracked_hash,
      :format => :gif
    )
  end
end