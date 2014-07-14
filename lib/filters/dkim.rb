class Filters::Dkim < Filters::Delivery
  # TODO Check from is correct. Otherwise don't apply dkim

  def data
    if delivery.app.dkim_enabled
      Dkim.sign(delivery.data, selector: 'cuttlefish', private_key: delivery.app.dkim_key, domain: delivery.app.from_domain)
    else
      delivery.data
    end
  end
end
