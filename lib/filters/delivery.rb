class Filters::Delivery
  attr_accessor :previous_filter

  def initialize(delivery)
    @delivery = delivery
  end

  def input_data(content)
    if previous_filter.nil?
      content
    else
      previous_filter.data(content)
    end
  end

  # Override this method
  def data(content)
    data2(input_data(content))
  end

  # Override this method
  def data2(content)
    content
  end
end
