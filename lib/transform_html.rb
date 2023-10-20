# Utility for doing the transformations we need to do on HTML for Cuttlefish
# Just handy to have them all in the same place
class TransformHtml
  attr_reader :html

  def initialize(html)
    @html = html
  end

  def inline_css_remove_style_blocks_and_replace_body_with_div
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
