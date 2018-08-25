class Types::Configuration < Types::Base::Object
  description "Application configuration settings"
  field :max_no_emails_to_store, Int, null: false, description: "The maximum number of emails for which the full content is stored"
  field :domain, String, null: false, description: "The domain that this cuttlefish server is running on"

  def domain
    object.cuttlefish_domain
  end
end
