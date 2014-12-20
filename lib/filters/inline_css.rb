class Filters::InlineCss < Filters::Mail
  def initialize
  end
  
  def filter_html(input)
    premailer = Premailer.new(input, with_html_string: true, input_encoding: input.encoding.to_s)
    premailer.to_inline_css
  end
end
