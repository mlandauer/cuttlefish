class Types::DkimType < Types::Base::Object
  description "Details of DKIM setup"

  field :enabled, Boolean, null: false, description: "Whether DKIM is enabled"
  field :legacy_selector, Boolean, null: false, description: "Whether we're using the original form of the DNS record for DKIM"

  def enabled
    object.dkim_enabled
  end

  def legacy_selector
    object.legacy_dkim_selector
  end
end
