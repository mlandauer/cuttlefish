module EmailsHelper
  # Give a warning level (used for colouring things in Bootstrap) based on whether the email has
  # been delivered succesfully
  def delivered_class(status)
    case status
    when "delivered"
      "success"
    when "soft_bounce"
      "warning"
    when "hard_bounce"
      "error"
    when "unknown"
      nil
    else
      raise "Unknown status"
    end
  end

  def label_class2(status)
    case status
    when "delivered"
      "label-success"
    when "soft_bounce"
      "label-warning"
    when "hard_bounce"
      "label-important"
    when "unknown"
      nil
    else
      raise "Unknown status"
    end
  end

  def label_class(status)
    ["label", label_class2(status)]
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
