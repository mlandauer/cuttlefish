class Filters::Dkim < Filters::Base
  attr_reader :options

  # options: enabled, domain, key, sender_email
  def initialize(options)
    @options = options
  end

  def filter_mail(mail)
    if active?(mail)
      Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: options[:key], domain: options[:domain]))
    else
      mail.sender = options[:sender_email]
      # TODO Sign with DKIM for cuttlefish_sender_email domain if available
      mail
    end
  end

  def active?(mail)
    address = mail.sender || mail.from.first
    from_domain = address.split("@")[1]
    options[:enabled] && from_domain == options[:domain]
  end
end
