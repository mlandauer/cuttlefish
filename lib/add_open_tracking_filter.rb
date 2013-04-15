# Insert a tracking image at the bottom of the html email
class AddOpenTrackingFilter < DeliveryFilter
  def data
    mail = Mail.new(delivery.data)
    new_html = mail.parts.first.body.decoded + '<img src="http://foo.com/track.gif">'
    mail.parts.first.body = new_html
    mail.encoded
  end
end