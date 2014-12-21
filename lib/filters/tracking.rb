class Filters::Tracking < Filters::Mail
  # Hostname to use for the open tracking image or rewritten link
  def host
    if Rails.env.development?
      "localhost:3000"
    else
      delivery.tracking_domain
    end
  end

  # Whether to use ssl for the open tracking image or rewritten link
  def protocol
    !delivery.custom_tracking_domain? && !Rails.env.development? ? "https" : "http"
  end
end
