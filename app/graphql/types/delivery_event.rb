class Types::DeliveryEvent < GraphQL::Schema::Object
  description "Information about an attempt to deliver an email"
  field :time, Types::DateTime, null: false, description: "Time of the event"
  field :dsn, String, null: false, description: "The Delivery Status Notification"
  field :extended_status, String, null: false, description: "An extended status description of the event"
end
