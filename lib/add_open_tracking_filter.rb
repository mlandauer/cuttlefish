# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def data
    if has_html_part?
      delivery.update_attribute(:open_tracked, true)
      append_to_html(image_tag(delivery_open_track_url(:id => id, :host => host, :format => :gif), :alt => nil))
    else
      delivery.data
    end
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

  def host
    Rails.configuration.action_mailer.default_url_options[:host]
  end
end