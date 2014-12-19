class Filters::Dkim < Filters::Base
  def filter(content)
    filter_mail(Mail.new(content)).to_s
  end

  def filter_mail(mail)
    if active?
      Mail.new(Dkim.sign(mail.to_s, selector: 'cuttlefish', private_key: delivery.app.dkim_key, domain: delivery.app.from_domain))
    else
      mail
    end
  end

  def active?
    delivery.app.dkim_enabled && delivery.from_domain == delivery.app.from_domain
  end
end
