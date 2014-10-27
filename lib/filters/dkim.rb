class Filters::Dkim < Filters::Delivery
  def data(delivery)
    if active?
      Dkim.sign(filter.data(delivery), selector: 'cuttlefish', private_key: filter.app.dkim_key, domain: filter.app.from_domain)
    else
      filter.data(delivery)
    end
  end

  def active?
    filter.app.dkim_enabled && filter.from_domain == filter.app.from_domain
  end
end
