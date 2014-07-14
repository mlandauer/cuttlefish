class Filters::Delivery
  attr_reader :delivery

  def initialize(delivery)
    @delivery = delivery
  end

  def from
    delivery.from
  end

  def to
    delivery.to
  end

  def data
    delivery.data
  end

  def send?
    delivery.respond_to?(:send?) ? delivery.send? : true
  end

  def method_missing(name, *args, &block)
    delivery.send name, *args, &block
  end
end
