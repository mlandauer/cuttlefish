# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  include ActionView::Helpers::AssetTagHelper

  def data
    mail = Mail.new(delivery.data)
    new_html = mail.parts.first.body.decoded +
      image_tag("http://foo.com/track.gif", :alt => nil)
    mail.parts.first.body = new_html
    mail.encoded
  end
end