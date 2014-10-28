class Filters::InlineCss < Filters::Tracking
  def process_html(input, delivery)
    premailer = Premailer.new(input, with_html_string: true)
    premailer.to_inline_css
  end
end
