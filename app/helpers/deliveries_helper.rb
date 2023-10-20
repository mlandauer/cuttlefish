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
    TransformHtml.new(html).inline_css_remove_style_blocks_and_replace_body_with_div
  end
end
