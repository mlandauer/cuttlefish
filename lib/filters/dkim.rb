class Filters::Dkim < Filters::Delivery
  # TODO Check from is correct. Otherwise don't apply dkim
  
  def data
    if delivery.app.dkim_enabled
      private_key = OpenSSL::PKey::RSA.new(delivery.app.dkim_private_key)
      Dkim.sign(delivery.data, selector: 'cuttlefish', private_key: private_key, domain: delivery.app.from_domain)
    else
      delivery.data
    end
  end
end
