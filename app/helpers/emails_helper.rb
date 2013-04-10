module EmailsHelper
  # Give a warning level (used for colouring things in Bootstrap) based on whether the email has
  # been delivered succesfully
  def delivered_class(email)
    if email.delivered == true
      "success"
    elsif email.delivered == false
      "warning"
    end
  end

  def delivered_label(status)
    if status == "delivered"
      content_tag(:span, "Delivered", :class => "label label-success")
    elsif status == "soft_bounce"
      content_tag(:span, "Soft bounce", :class => "label label-warning")
    elsif status == "hard_bounce"
      content_tag(:span, "Hard bounce", :class => "label label-warning")
    elsif status == "unknown"
      content_tag(:span, "Unknown", :class => "label")
    else
      raise "Unknown status"
    end
  end
end
