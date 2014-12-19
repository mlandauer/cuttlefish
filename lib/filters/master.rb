class Filters::Master
  def data(delivery)
    filter1 = Filters::AddOpenTracking.new
    filter2 = Filters::ClickTracking.new
    filter2.previous_filter = filter1
    filter3 = Filters::InlineCss.new
    filter3.previous_filter = filter2
    filter4 = Filters::MailerHeader.new
    filter4.previous_filter = filter3
    # DKIM filter needs to always be the last one
    filter5 = Filters::Dkim.new
    filter5.previous_filter = filter4
    filter5.data(delivery)
  end
end
