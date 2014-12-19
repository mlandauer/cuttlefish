class Filters::Master
  def data(delivery)
    filter1 = Filters::AddOpenTracking.new
    filter2 = Filters::ClickTracking.new
    filter2.next_filter = filter1
    filter3 = Filters::InlineCss.new
    filter3.next_filter = filter2
    filter4 = Filters::MailerHeader.new
    filter4.next_filter = filter3
    # DKIM filter needs to always be the last one
    filter5 = Filters::Dkim.new
    filter5.next_filter = filter4
    filter5.data(delivery)
  end
end
