# Filter mail content by splitting out html and text parts
# and handling them separately
class Filters::Mail < Filters::Base
  def filter(content)
    mail = Mail.new(content)
    if mail.multipart?
      mail.html_part.body = process_html(mail.html_part.decoded) if mail.html_part
      mail.text_part.body = process_text(mail.text_part.decoded) if mail.text_part
    else
      if mail.mime_type == "text/html"
        mail.body = process_html(mail.decoded)
      else
        mail.body = process_text(mail.decoded)
      end
    end
    mail.encoded
  end

  # Override the following two methods in inherited class
  def process_text(input)
    input
  end

  def process_html(input)
    input
  end
end
