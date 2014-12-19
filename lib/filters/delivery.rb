class Filters::Delivery
  attr_accessor :previous_filter

  def initialize(delivery)
    @delivery = delivery
  end

  def input_data2(content)
    if previous_filter.nil?
      content
    else
      previous_filter.data2(content)
    end
  end

  # Override this method
  def data2(content)
    input_data2(content)
  end
end
