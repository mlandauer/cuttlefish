class Filters::Master < Filters::Delivery
  def data
    # DKIM filter needs to always be the last one
    filtered = Filters::Dkim.new(Filters::ClickTracking.new(Filters::AddOpenTracking.new(filter)))
    filtered.data
  end
end
