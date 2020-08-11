# frozen_string_literal: true

module EmailsHelper
  # Mapping from status strings to bootstrap classes
  # The naming of the bootstrap classes is not entirely consistent. There are
  # two variants
  def bootstrap_status_class(status, variant: false)
    map = {
      "not_sent" => "info",
      "sent" => "success",
      "delivered" => "success",
      "soft_bounce" => "warning"
    }
    map["hard_bounce"] = variant ? "important" : "error"

    raise "Unknown status" unless map.key?(status)

    map[status]
  end

  def label_class(status)
    if bootstrap_status_class(status, variant: true)
      label_class = "label-#{bootstrap_status_class(status, variant: true)}"
    end
    ["label", label_class]
  end

  def badge_class(status)
    ["badge", "badge-#{bootstrap_status_class(status, variant: true)}"]
  end

  def status_name(status)
    case status
    when "not_sent"
      "Held back"
    when "sent"
      "Sent"
    when "delivered"
      "Delivered"
    when "soft_bounce"
      "Soft bounce"
    when "hard_bounce"
      "Hard bounce"
    else
      raise "Unknown status"
    end
  end

  def delivered_label(status)
    content_tag(:span, status_name(status), class: label_class(status))
  end
end
