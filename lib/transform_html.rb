# Utility for doing the transformations we need to do on HTML for Cuttlefish
# Just handy to have them all in the same place
class TransformHtml
  attr_reader :html

  def initialize(html)
    @html = html
  end

  # Pass block with function that returns new url given current url
  def rewrite_links
    doc = nokogiri
    doc.search("a[href]").each do |a|
      a["href"] = yield(a["href"])
    end
    doc.to_s
  end

  def html5?
    html[0..14] == "<!DOCTYPE html>"
  end

  def inline_css
    Premailer.new(
      html,
      with_html_string: true,
      input_encoding: html.encoding.to_s,
      adapter: (html5? ? :nokogumbo : :nokogiri)
    ).to_inline_css
  end

  def inline_css_remove_style_blocks_and_replace_body_with_div
    doc = TransformHtml.new(inline_css).nokogiri
    doc.search("style").remove
    body = doc.at("body")
    body.name = "div"
    body.to_s.html_safe
  end

  # Use an html5 or html4 parser based on the doctype
  def nokogiri
    html5? ? Nokogiri::HTML5(html) : Nokogiri::HTML(html)
  end
end
