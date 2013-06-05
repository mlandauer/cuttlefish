class LinkTrackingFilter < MailFilter
  def apply_html?
    true
  end

  def process_html(input)
    doc = Nokogiri::HTML(input)
    doc.search("a[href]").each do |a|
      a["href"] = LinkTrackingFilter.rewrite_url(a["href"])
    end
    doc.to_s
  end
end