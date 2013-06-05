class LinkTrackingFilter < TrackingFilter
  include Rails.application.routes.url_helpers

  def rewrite_url(url)
    link = Link.find_or_create_by(url: url)
    delivery_link = DeliveryLink.find_or_create_by(delivery_id: id, link_id: link.id)
    tracking_link_url(
      host: host, 
      protocol: protocol,
      :delivery_link_id => delivery_link.id,
      :hash => delivery_link.hash
    )    
  end

  def apply_html?
    true
  end

  def process_html(input)
    doc = Nokogiri::HTML(input)
    doc.search("a[href]").each do |a|
      a["href"] = rewrite_url(a["href"])
    end
    doc.to_s
  end
end