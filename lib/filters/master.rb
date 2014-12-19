class Filters::Master < Filters::Base
  def filter(content)
    filter_mail(Mail.new(content)).to_s
  end

  def filter_mail(mail)
    filtered1 = Filters::AddOpenTracking.new(delivery).filter_mail(mail)
    filtered2 = Filters::ClickTracking.new(delivery).filter_mail(filtered1)
    filtered3 = Filters::InlineCss.new(delivery).filter_mail(filtered2)
    filtered4 = Filters::MailerHeader.new(delivery).filter_mail(filtered3)
    # DKIM filter needs to always be the last one
    Filters::Dkim.new(delivery).filter_mail(filtered4)
  end
end
