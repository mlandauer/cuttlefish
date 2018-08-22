class Types::DkimType < Types::Base::Object
  description "Details of DKIM setup"

  field :enabled, Boolean, null: false, description: "Whether DKIM is enabled"
  field :legacy_selector, Boolean, null: false, description: "Whether we're using the original form of the DNS record for DKIM"
  field :dns_configured, Boolean, null: false, description: "Queries DNS to check whether the record for DKIM is correctly configured"
  field :lookup_dns_value, String, null: true, description: "Queries DNS for the current value of the DKIM record. Returns null if there is no record."
  field :dns_name, String, null: false, description: "The fully qualified domain name for the DKIM DNS record"
  field :dns_value, String, null: false, description: "The value that the DKIM record should have"

  def enabled
    object.dkim_enabled
  end

  def legacy_selector
    object.legacy_dkim_selector
  end

  def dns_configured
    dkim_dns.dkim_dns_configured?
  end

  def lookup_dns_value
    dkim_dns.resolve_dkim_dns_value
  end

  def dns_name
    dkim_dns.dkim_domain
  end

  def dns_value
    dkim_dns.dkim_dns_value
  end

  private

  def dkim_dns
    DkimDns.new(
      domain: object.from_domain,
      private_key: object.dkim_private_key,
      # Always use the new version of the selector
      selector: object.dkim_selector_current_value
    )
  end
end
