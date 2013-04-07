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

  def delivered_label(delivered)
    if delivered == true
      content_tag(:span, "Delivered", :class => "label label-success")
    elsif delivered == false
      content_tag(:span, "Not delivered", :class => "label label-warning")
    else
      content_tag(:span, "Delivery status unknown", :class => "label")
    end
  end
end
