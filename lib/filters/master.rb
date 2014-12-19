class Filters::Master < Filters::Base
  def filter_mail(mail)
    content = mail.to_s
    filtered1 = Filters::AddOpenTracking.new(delivery).filter(content)
    filtered2 = Filters::ClickTracking.new(delivery).filter(filtered1)
    filtered3 = Filters::InlineCss.new(delivery).filter(filtered2)
    filtered4 = Filters::MailerHeader.new(delivery).filter(filtered3)
    # DKIM filter needs to always be the last one
    Mail.new(Filters::Dkim.new(delivery).filter(filtered4))
  end
end
