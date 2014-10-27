# Filter mail content by splitting out html and text parts
# and handling them separately
class Filters::Mail < Filters::Delivery
  def data
    mail = Mail.new(delivery.data)
    if mail.multipart?
      if (mail.html_part && apply_html?) || (mail.text_part && apply_text?)
        mail.html_part.body = process_html(mail.html_part.body.decoded) if mail.html_part && apply_html?
        mail.text_part.body = process_text(mail.text_part.body.decoded) if mail.text_part && apply_text?
        mail.encoded
      else
        # If we don't need to change either the html or text part don't risk the conversion back and forth between text and Mail representation.
        # Just pass stuff straight through instead
        delivery.data
      end
    else
      if mail.mime_type == "text/html" && apply_html?
        mail.body = process_html(mail.body.decoded)
        mail.encoded
      elsif apply_text?
        mail.body = process_text(mail.body.decoded)
        mail.encoded
      else
        # Do nothing
        delivery.data
      end
    end
  end

  # Override the following four methods in inherited class
  def process_text(input)
    input
  end

  def process_html(input)
    input
  end

  def apply_text?
    true
  end

  def apply_html?
    true
  end
end
