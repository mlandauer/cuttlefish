class Filters::Delivery
  attr_reader :filter

  def initialize(filter = nil)
    @filter = filter
  end

  def input_data(delivery)
    if filter.nil?
      delivery.data
    else
      filter.data(delivery)
    end
  end

  # Override this method
  def data(delivery)
    input_data(delivery)
  end
end
