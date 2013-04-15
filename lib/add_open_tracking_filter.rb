# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  include ActionView::Helpers::AssetTagHelper
  include Rails.application.routes.url_helpers

  def data
    mail = Mail.new(delivery.data)
    new_html = mail.parts.first.body.decoded +
      image_tag(delivery_open_track_url(:id => "123", :host => Rails.configuration.action_mailer.default_url_options[:host], :format => :gif), :alt => nil)
    mail.parts.first.body = new_html
    mail.encoded
  end
end