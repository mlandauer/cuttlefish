# Filter mail content by splitting out html and text parts
# and handling them separately
class Filters::Mail < Filters::Delivery
  def data(content)
    mail = Mail.new(input_data(content))
    if mail.multipart?
      mail.html_part.body = process_html(mail.html_part.decoded, @delivery) if mail.html_part
      mail.text_part.body = process_text(mail.text_part.decoded, @delivery) if mail.text_part
    else
      if mail.mime_type == "text/html"
        mail.body = process_html(mail.decoded, @delivery)
      else
        mail.body = process_text(mail.decoded, @delivery)
      end
    end
    mail.encoded
  end

  # Override the following two methods in inherited class
  def process_text(input, delivery)
    input
  end

  def process_html(input, delivery)
    input
  end
end
