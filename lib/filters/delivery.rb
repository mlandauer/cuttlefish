class Filters::Delivery
  attr_accessor :previous_filter

  def initialize(delivery)
    @delivery = delivery
  end

  def output_data(content)
    if previous_filter.nil?
      data2(content)
    else
      data2(previous_filter.output_data(content))
    end
  end

  # Override this method
  def data2(content)
    content
  end
end
