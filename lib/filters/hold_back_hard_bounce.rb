class Filters::HoldBackHardBounce < Filters::Delivery
  # Should this email be sent to this address?
  # If not it's because the email has bounced
  def send?
    delivery.address.status != "hard_bounce"
  end
end
