class Filters::Master
  def data(delivery)
    filtered1 = Filters::AddOpenTracking.new(delivery).filter(delivery.data)
    filtered2 = Filters::ClickTracking.new(delivery).filter(filtered1)
    filtered3 = Filters::InlineCss.new(delivery).filter(filtered2)
    filtered4 = Filters::MailerHeader.new(delivery).filter(filtered3)
    # DKIM filter needs to always be the last one
    Filters::Dkim.new(delivery).filter(filtered4)
  end
end
