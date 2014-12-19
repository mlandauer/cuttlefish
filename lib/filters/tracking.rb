class Filters::Tracking < Filters::Mail
  # Hostname to use for the open tracking image or rewritten link
  def host
    if !delivery.email.custom_tracking_domain.blank?
      delivery.email.custom_tracking_domain
    elsif Rails.env.development?
      "localhost:3000"
    else
      Rails.configuration.cuttlefish_domain
    end
  end

  # Whether to use ssl for the open tracking image or rewritten link
  def protocol
    delivery.email.custom_tracking_domain.blank? && !Rails.env.development? ? "https" : "http"
  end
end
