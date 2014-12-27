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
    unless in_correct_domain?(mail, domain) && enabled
      mail.sender = sender_email
    end

    if in_correct_domain?(mail, domain) && enabled
      mail = Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: key, domain: domain))
    end
    if in_correct_domain?(mail, cuttlefish_domain) && cuttlefish_enabled
      mail = Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: cuttlefish_key, domain: cuttlefish_domain))
    end

    mail
  end

  def in_correct_domain?(mail, domain)
    (mail.sender || mail.from.first).split("@")[1] == domain
  end
end
