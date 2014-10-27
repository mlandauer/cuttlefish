class Filters::Dkim < Filters::Delivery
  def data
    if active?
      Dkim.sign(filter.data, selector: 'cuttlefish', private_key: filter.app.dkim_key, domain: filter.app.from_domain)
    else
      filter.data
    end
  end

  def active?
    filter.app.dkim_enabled && filter.from_domain == filter.app.from_domain
  end
end
