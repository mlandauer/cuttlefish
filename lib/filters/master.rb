class Filters::Master
  def data(delivery)
    # DKIM filter needs to always be the last one
    filtered = Filters::Dkim.new(Filters::MailerHeader.new(Filters::InlineCss.new(Filters::ClickTracking.new(Filters::AddOpenTracking.new))))
    filtered.data(delivery)
  end
end
