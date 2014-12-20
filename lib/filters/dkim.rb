class Filters::Dkim < Filters::Base
  attr_accessor :key, :domain, :sender_email, :enabled

  def initialize(options)
    @enabled = options[:enabled]
    @key = options[:key]
    @domain = options[:domain]
    @sender_email = options[:sender_email]
  end

  def filter_mail(mail)
    if active?(mail)
      Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: key, domain: domain))
    else
      mail.sender = sender_email
      # TODO Sign with DKIM for cuttlefish_sender_email domain if available
      mail
    end
  end

  def active?(mail)
    address = mail.sender || mail.from.first
    from_domain = address.split("@")[1]
    enabled && from_domain == domain
  end
end
