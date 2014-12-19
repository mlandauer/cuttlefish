class Filters::Delivery
  attr_accessor :previous_filter

  def initialize(delivery)
    @delivery = delivery
  end

  def output_data(content)
    if previous_filter.nil?
      filter(content)
    else
      filter(previous_filter.output_data(content))
    end
  end

  # Override this method
  def filter(content)
    content
  end
end
