class HoldBackHardBounceFilter
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

  # Should this email be sent to this address?
  # If not it's because the email has bounced
  def send?
    delivery.address.status != "hard_bounce"
  end
end
