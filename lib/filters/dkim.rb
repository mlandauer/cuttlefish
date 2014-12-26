class Filters::Dkim < Filters::Base
  attr_accessor :key, :domain, :sender_email, :enabled,
    :cuttlefish_enabled, :cuttlefish_key, :cuttlefish_domain

  def initialize(options)
    @enabled = options[:enabled]
    @key = options[:key]
    @domain = options[:domain]
    @cuttlefish_enabled = options[:cuttlefish_enabled]
    @cuttlefish_key = options[:cuttlefish_key]
    @cuttlefish_domain = options[:cuttlefish_domain]
    @sender_email = options[:sender_email]
  end

  def filter_mail(mail)
    if active?(mail)
      Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: key, domain: domain))
    else
      mail.sender = sender_email
      from_domain = mail.sender.split("@")[1]
      if cuttlefish_enabled && from_domain == cuttlefish_domain
        Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: cuttlefish_key, domain: cuttlefish_domain))
      else
        mail
      end
    end
  end

  def active?(mail)
    address = mail.sender || mail.from.first
    from_domain = address.split("@")[1]
    enabled && from_domain == domain
  end
end
