module EmailsHelper
  # Give a warning level (used for colouring things in Bootstrap) based on whether the email has
  # been delivered succesfully
  def row_status_class(status)
    map = {
      "delivered" => "success",
      "soft_bounce" => "warning",
      "hard_bounce" => "error",
      "unknown" => nil
    }
    raise "Unknown status" unless map.has_key?(status)
    map[status]
  end

  def status_class_category(status)
    map = {
      "delivered" => "success",
      "soft_bounce" => "warning",
      "hard_bounce" => "important",
      "unknown" => nil
    }
    raise "Unknown status" unless map.has_key?(status)
    map[status]
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
