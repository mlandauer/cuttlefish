class Types::ConfigurationType < Types::Base::Object
  description "Application configuration settings"
  field :max_no_emails_to_store, Int, null: false, description: "The maximum number of emails for which the full content is stored"
end
