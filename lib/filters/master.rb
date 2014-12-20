class Filters::Master < Filters::Base
  def filter(content)
    filter_mail(Mail.new(content)).to_s
  end

  def filter_mail(mail)
    filtered1 = Filters::AddOpenTracking.new(delivery).filter_mail(mail)
    filtered2 = Filters::ClickTracking.new(delivery).filter_mail(filtered1)
    filtered3 = Filters::InlineCss.new.filter_mail(filtered2)
    filtered4 = Filters::MailerHeader.new(delivery).filter_mail(filtered3)
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
