class Filters::Delivery
  attr_accessor :previous_filter

  def initialize(delivery)
    @delivery = delivery
  end

  def input_data(delivery)
    if previous_filter.nil?
      delivery.data
    else
      previous_filter.data(delivery)
    end
  end

  def input_data2(content)
    if previous_filter.nil?
      content
    else
      previous_filter.data2(content)
    end
  end

  # Override this method
  def data(delivery)
    input_data(delivery)
  end

  # Override this method
  def data2(content)
    input_data2(content)
  end
end
