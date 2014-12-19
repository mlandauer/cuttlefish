class Filters::ClickTracking < Filters::Tracking
  include Rails.application.routes.url_helpers

  def rewrite_url(url)
    link = Link.find_or_create_by(url: url)
    delivery_link = DeliveryLink.find_or_create_by(delivery_id: delivery.id, link_id: link.id)
    tracking_click_url(
      host: host,
      protocol: protocol,
      delivery_link_id: delivery_link.id,
      hash: HashId.hash(delivery_link.id),
      url: url
    )
  end

  def filter_html(input)
    if delivery.click_tracking_enabled?
      doc = Nokogiri::HTML(input)
      doc.search("a[href]").each do |a|
        a["href"] = rewrite_url(a["href"])
      end
      doc.to_s
    else
      input
    end
  end
end
