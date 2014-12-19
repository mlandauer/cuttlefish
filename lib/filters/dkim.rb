class Filters::Dkim < Filters::Base
  def filter(content)
    if active?
      Dkim.sign(content, selector: 'cuttlefish', private_key: delivery.app.dkim_key, domain: delivery.app.from_domain)
    else
      content
    end
  end

  def active?
    delivery.app.dkim_enabled && delivery.from_domain == delivery.app.from_domain
  end
end
