module EmailsHelper
  # Mapping from status strings to bootstrap classes
  # The naming of the bootstrap classes is not entirely consistent. There are two variants
  def bootstrap_status_class(status, variant = false)
    map = {
      "delivered" => "success",
      "soft_bounce" => "warning",
      "unknown" => nil
    }
    map["hard_bounce"] = variant ? "important" : "error"

    raise "Unknown status" unless map.has_key?(status)
    map[status]
  end

  def status_class_category(status)
    bootstrap_status_class(status, true)
  end

  def label_class(status)
    ["label", ("label-#{status_class_category(status)}" if status_class_category(status))]
  end

  def status_name(status)
    case status
    when "delivered"
      "Delivered"
    when "soft_bounce"
      "Soft bounce"
    when "hard_bounce"
      "Hard bounce"
    when "unknown"
      "Unknown"
    else
      raise "Unknown status"
    end
  end

  def delivered_label(status)
    content_tag(:span, status_name(status), :class => label_class(status))
  end
end
