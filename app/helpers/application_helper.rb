module ApplicationHelper
  ALERT_TYPES = [:error, :info, :success, :warning]

  # From twitter-bootstrap-rails gem
  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?
      
      type = :success if type == :notice
      type = :error   if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end

  def nav_menu_item(*args, &block)
    if block_given?
      link = link_to(args[0], &block)
      current = current_page?(args[0])
    else
      link = link_to(args[0], args[1])
      current = current_page?(args[1])
    end
    content_tag(:li, link, class: ("active" if current))
  end
end
