class DeliveryFilter
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
    true
  end
end
