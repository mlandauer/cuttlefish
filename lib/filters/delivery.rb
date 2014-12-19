class Filters::Delivery
  attr_accessor :previous_filter

  def input_data(delivery)
    if previous_filter.nil?
      delivery.data
    else
      previous_filter.data(delivery)
    end
  end

  # Override this method
  def data(delivery)
    input_data(delivery)
  end
end
