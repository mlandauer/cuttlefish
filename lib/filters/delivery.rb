class Filters::Delivery
  attr_reader :delivery

  def initialize(delivery)
    @delivery = delivery
  end

  def data
    delivery.data
  end

  def method_missing(name, *args, &block)
    delivery.send name, *args, &block
  end
end
