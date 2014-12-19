class Filters::Dkim < Filters::Delivery
  def data(content)
    if active?
      Dkim.sign(input_data(content), selector: 'cuttlefish', private_key: @delivery.app.dkim_key, domain: @delivery.app.from_domain)
    else
      input_data(content)
    end
  end

  def active?
    @delivery.app.dkim_enabled && @delivery.from_domain == @delivery.app.from_domain
  end
end
