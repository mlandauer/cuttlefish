# frozen_string_literal: true

module AppsHelper
  # If a DNS TXT record is longer than 255 characters it needs to be split into several
  # separate strings. Some DNS hosting services (e.g. DNS Made Easy) expect strings
  # to be formatted in this way.
  def quote_long_dns_txt_record(text)
    text.scan(/.{1,255}/).map { |s| '"' + s + '"' }.join
  end
end
