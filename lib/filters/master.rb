class Filters::Master < Filters::Base
  def filter(content)
    filter_mail(Mail.new(content)).to_s
  end

  def filter_mail(mail)
    filtered1 = Filters::AddOpenTracking.new(delivery).filter_mail(mail)
    filter2 = Filters::ClickTracking.new(
      delivery_id: delivery.id,
      enabled: delivery.click_tracking_enabled?,
      tracking_domain: delivery.tracking_domain,
      using_custom_tracking_domain: delivery.custom_tracking_domain?
    )
    filtered2 = filter2.filter_mail(filtered1)
    filtered3 = Filters::InlineCss.new.filter_mail(filtered2)
    filter4 = Filters::MailerHeader.new(version: APP_VERSION)
    filtered4 = filter4.filter_mail(filtered3)
    # DKIM filter needs to always be the last one
    filter5 = Filters::Dkim.new(
      enabled: delivery.app.dkim_enabled,
      domain: delivery.app.from_domain,
      key: delivery.app.dkim_key,
      sender_email: Rails.configuration.cuttlefish_sender_email
    )
    filter5.filter_mail(filtered4)
  end
end
