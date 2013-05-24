# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def data
    if has_html_part?
      delivery.set_open_tracked!
      append_to_html(image_tag(url, :alt => nil))
    else
      delivery.data
    end
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
    if !email.open_tracking_domain.blank?
      email.open_tracking_domain
    elsif Rails.env.development?
      "localhost:3000"
    else
      Rails.configuration.cuttlefish_domain
    end
  end

  # Whether to use ssl for the open tracking image
  def protocol
    email.open_tracking_domain.blank? && !Rails.env.development? ? "https" : "http"
  end

  private

  def append_to_html(to_append)
    m = mail
    m.html_part.body = m.html_part.body.decoded + to_append
    m.encoded
  end

  def mail
    Mail.new(delivery.data)
  end

  def has_html_part?
    !!mail.html_part
  end
end