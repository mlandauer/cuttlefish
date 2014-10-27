class Filters::Delivery
  attr_reader :filter

  def initialize(filter)
    @filter = filter
  end

  def input_data(delivery)
    # Temporary hack
    if filter.kind_of?(Delivery)
      filter.data
    else
      filter.data(delivery)
    end
  end

  def data(delivery)
    filter.data
  end

  def method_missing(name, *args, &block)
    filter.send name, *args, &block
  end
end
