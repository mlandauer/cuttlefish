# Filter mail content by splitting out html and text parts
# and handling them separately
class Filters::Mail < Filters::Delivery
  def data(delivery)
    mail = Mail.new(input_data(delivery))
    if mail.multipart?
      mail.html_part.body = process_html(mail.html_part.body.decoded) if mail.html_part
      mail.text_part.body = process_text(mail.text_part.body.decoded) if mail.text_part
    else
      if mail.mime_type == "text/html"
        mail.body = process_html(mail.body.decoded)
      else
        mail.body = process_text(mail.body.decoded)
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
