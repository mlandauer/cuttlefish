class Filters::Master
  def data(delivery)
    filter1 = Filters::AddOpenTracking.new(delivery)
    filter2 = Filters::ClickTracking.new(delivery)
    filter2.previous_filter = filter1
    filter3 = Filters::InlineCss.new(delivery)
    filter3.previous_filter = filter2
    filter4 = Filters::MailerHeader.new(delivery)
    filter4.previous_filter = filter3
    # DKIM filter needs to always be the last one
    filter5 = Filters::Dkim.new(delivery)
    filter5.previous_filter = filter4
    filter5.data(delivery.data)
  end
end
