# Filter mail content by splitting out html and text parts
# and handling them separately
class MailFilter < DeliveryFilter
  def data
    mail = Mail.new(delivery.data)
    if (mail.html_part && apply_html?) || (mail.text_part && apply_text?)
      process_mail(mail).encoded
    else
      # If we don't need to change either the html or text part don't risk the conversion back and forth between text and Mail representation.
      # Just pass stuff straight through instead
      delivery.data
    end
  end

  def process_mail(m)
    m.html_part.body = process_html(m.html_part.body.decoded) if m.html_part && apply_html?
    m.text_part.body = process_text(m.text_part.body.decoded) if m.text_part && apply_text?
    m
  end

  # Override the following four methods in inherited class
  def process_text(input)
  end

  def process_html(input)
  end

  def apply_text?
    false
  end

  def apply_html?
    false
  end
end
