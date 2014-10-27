class Filters::Delivery
  attr_reader :filter

  def initialize(filter)
    @filter = filter
  end

  def data
    filter.data
  end

  def method_missing(name, *args, &block)
    filter.send name, *args, &block
  end
end
