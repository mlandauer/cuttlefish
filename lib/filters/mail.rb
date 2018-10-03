# frozen_string_literal: true

# Filter mail content by splitting out html and text parts
# and handling them separately
module Filters
  class Mail < Filters::Base
    def filter_mail(mail)
      if mail.multipart?
        if mail.html_part
          mail.html_part.body = filter_html(mail.html_part.body.decoded)
        end
        if mail.text_part
          mail.text_part.body = filter_text(mail.text_part.body.decoded)
        end
      else
        mail.body = if mail.mime_type == "text/html"
                      filter_html(mail.body.decoded)
                    else
                      filter_text(mail.body.decoded)
                    end
      end
      mail
    end

    # Override the following two methods in inherited class
    # Whatever you do don't change the encoding of the string because it will
    # break things
    def filter_text(input)
      input
    end

    def filter_html(input)
      input
    end
  end
end
