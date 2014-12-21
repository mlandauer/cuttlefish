class Filters::Tracking < Filters::Mail
  # Hostname to use for the open tracking image or rewritten link
  def host
    if Rails.env.development?
      "localhost:3000"
    elsif delivery.email.custom_tracking_domain.present?
      delivery.email.custom_tracking_domain
    else
      Rails.configuration.cuttlefish_domain
    end
  end

  # Whether to use ssl for the open tracking image or rewritten link
  def protocol
    delivery.email.custom_tracking_domain.blank? && !Rails.env.development? ? "https" : "http"
  end
end
