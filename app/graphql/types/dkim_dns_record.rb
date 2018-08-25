class Types::DkimDnsRecord < Types::Base::Object
  description "Details of the DKIM DNS record"

  field :upgrade_required, Boolean, null: false, description: "Whether a change to the the new form of the DKIM record is required"
  field :name, String, null: false, description: "The fully qualified domain name for the DKIM DNS record"
  field :lookup_value, String, null: true, description: "Queries DNS for the current value of the DKIM record. Returns null if there is no record."
  field :target_value, String, null: false, description: "The value that the DKIM record should have"
  field :configured, Boolean, null: false, description: "If lookupValue == targetValue. Queries DNS to check whether the record for DKIM is correctly configured"

  def enabled
    object.dkim_enabled
  end

  def upgrade_required
    object.legacy_dkim_selector
  end

  def configured
    dkim_dns.dkim_dns_configured?
  end

  def lookup_value
    dkim_dns.resolve_dkim_dns_value
  end

  def name
    dkim_dns.dkim_domain
  end

  def target_value
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
