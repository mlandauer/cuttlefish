class Types::DeliveryEventType < Types::BaseObject
  description "Information about an attempt to deliver an email"
  field :time, Types::DateTimeType, null: false, description: "Time of the event"
  field :dsn, String, null: false, description: "The Delivery Status Notification"
  field :extended_status, String, null: false, description: "An extended status description of the event"
end
