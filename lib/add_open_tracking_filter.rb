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
    # TODO Law of Demeter
    if email.app && email.app.open_tracking_domain
      tracking_open_url({protocol: "http", host: email.app.open_tracking_domain}.merge(:hash => open_tracked_hash, :format => :gif))
    else
      tracking_open_url(default_url_options.merge(:hash => open_tracked_hash, :format => :gif))
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

  def default_url_options
    if Rails.configuration.action_mailer.default_url_options
      Rails.configuration.action_mailer.default_url_options
    else
      raise "Set config.action_mailer.default_url_options in config/environments/#{Rails.env}.rb"
    end
  end
end