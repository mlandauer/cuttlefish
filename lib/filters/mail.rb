# Filter mail content by splitting out html and text parts
# and handling them separately
class Filters::Mail < Filters::Base
  def filter(content)
    filter_mail(Mail.new(content)).encoded
  end

  def filter_mail(mail)
    if mail.multipart?
      mail.html_part.body = filter_html(mail.html_part.decoded) if mail.html_part
      mail.text_part.body = filter_text(mail.text_part.decoded) if mail.text_part
    else
      if mail.mime_type == "text/html"
        mail.body = filter_html(mail.decoded)
      else
        mail.body = filter_text(mail.decoded)
      end
    end
    mail
  end

  # Override the following two methods in inherited class
  def filter_text(input)
    input
  end

  def filter_html(input)
    input
  end
end
