class Filters::Delivery
  attr_accessor :next_filter

  def input_data(delivery)
    if next_filter.nil?
      delivery.data
    else
      next_filter.data(delivery)
    end
  end

  # Override this method
  def data(delivery)
    input_data(delivery)
  end
end
