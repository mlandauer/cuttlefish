module EmailsHelper
  # Mapping from status strings to bootstrap classes
  # The naming of the classes is not entirely consistent. There are two variants
  def bootstrap_status_mapping(variant = false)
    map = {
      "delivered" => "success",
      "soft_bounce" => "warning",
      "unknown" => nil
    }
    map["hard_bounce"] = variant ? "important" : "error"
    map
  end

  # Give a warning level (used for colouring things in Bootstrap) based on whether the email has
  # been delivered succesfully
  def row_status_class(status)
    raise "Unknown status" unless bootstrap_status_mapping.has_key?(status)
    bootstrap_status_mapping[status]
  end

  def status_class_category(status)
    raise "Unknown status" unless bootstrap_status_mapping(true).has_key?(status)
    bootstrap_status_mapping(true)[status]
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
