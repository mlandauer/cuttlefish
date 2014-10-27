class Filters::Dkim < Filters::Delivery
  def data(delivery)
    if active?(delivery)
      Dkim.sign(input_data(delivery), selector: 'cuttlefish', private_key: delivery.app.dkim_key, domain: delivery.app.from_domain)
    else
      input_data(delivery)
    end
  end

  def active?(delivery)
    delivery.app.dkim_enabled && delivery.from_domain == delivery.app.from_domain
  end
end
