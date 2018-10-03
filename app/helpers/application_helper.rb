# frozen_string_literal: true

module ApplicationHelper
  ALERT_TYPES = ["error", "info", "success", "warning"]

  # From twitter-bootstrap-rails gem
  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = "success" if type == "notice"
      type = "error"   if type == "alert"
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), class: "close", "data-dismiss" => "alert") +
                           msg.html_safe, class: "alert fade in alert-#{type}")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end

  def nav_menu_item(*args, &block)
    if block_given?
      content_tag(:li, link_to(args[0], &block), args[1])
    else
      content_tag(:li, link_to(args[0], args[1], &block), args[2])
    end
  end

  def nav_menu_item_show_active(*args, &block)
    target = block_given? ? args[0] : args[1]
    args << {class: ("active" if current_page?(target))}
    nav_menu_item(*args, &block)
  end

  def admin_gravatar(admin)
    gravatar_image_tag(admin.email, gravatar: {size: 35, secure: true, default: :identicon}, class: "img-circle")
  end
end
