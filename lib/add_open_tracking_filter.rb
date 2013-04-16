# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def data
    append_to_html(delivery.data,
      image_tag(delivery_open_track_url(:id => id, :host => host, :format => :gif), :alt => nil))
  end

  private

  def append_to_html(data, to_append)
    mail = Mail.new(data)
    part = mail.html_part
    if part
      part.body = part.body.decoded + to_append
      mail.encoded
    else
      data
    end
  end

  def host
    Rails.configuration.action_mailer.default_url_options[:host]
  end
end