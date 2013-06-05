# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < MailFilter
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

  # Hostname to use for the open tracking image
  def host
    if !email.custom_tracking_domain.blank?
      email.custom_tracking_domain
    elsif Rails.env.development?
      "localhost:3000"
    else
      Rails.configuration.cuttlefish_domain
    end
  end

  # Whether to use ssl for the open tracking image
  def protocol
    email.custom_tracking_domain.blank? && !Rails.env.development? ? "https" : "http"
  end
end