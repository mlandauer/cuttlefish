# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def data
    mail = Mail.new(delivery.data)
    if mail.html_part
      new_html = mail.html_part.body.decoded +
        image_tag(delivery_open_track_url(:id => id, :host => host, :format => :gif), :alt => nil)
      mail.html_part.body = new_html
      mail.encoded
    else
      delivery.data
    end
  end

  private

  def host
    Rails.configuration.action_mailer.default_url_options[:host]
  end
end