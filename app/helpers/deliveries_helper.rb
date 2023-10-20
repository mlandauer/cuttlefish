# frozen_string_literal: true

module DeliveriesHelper
  def canonical_deliveries_path(app, status, search, key)
    if app
      app_deliveries_path(app, status: status, search: search, key: key)
    else
      deliveries_path(status: status, search: search, key: key)
    end
  end

  def clean_html_email_for_display(html)
    # Inline css so that email styling doesn't interfere with the cuttlefish ui
    # and only show the body of the html
    doc = if html[0..14] == "<!DOCTYPE html>"
      Nokogiri::HTML5(
        Premailer.new(
          html,
          with_html_string: true,
          input_encoding: html.encoding.to_s,
          adapter: :nokogumbo
        ).to_inline_css
      )
    else
      Nokogiri::HTML(
        Premailer.new(
          html,
          with_html_string: true,
          input_encoding: html.encoding.to_s
        ).to_inline_css
      )
    end
    doc.search("style").remove
    body = doc.at("body")
    body.name = "div"
    body.to_s.html_safe
  end
end
