module DeliveriesHelper
  def canonical_deliveries_path(app, status, search)
    if app
      app_deliveries_path(app, status: status, search: search)
    else
      deliveries_path(status: status, search: search)
    end
  end

  def clean_html_email_for_display(html)
    # Inline css so that email styling doesn't interfere with the cuttlefish ui
    # and only show the body of the html
    doc = Nokogiri::HTML(Premailer.new(html, with_html_string: true).to_inline_css)
    doc.search("style").remove
    body = doc.at("body")
    body.name = "div"
    body.to_s.html_safe
  end
end
