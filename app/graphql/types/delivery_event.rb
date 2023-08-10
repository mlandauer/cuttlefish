# frozen_string_literal: true

module Types
  class DeliveryEvent < GraphQL::Schema::Object
    description "Information about an attempt to deliver an email"
    field :dsn, String,
          null: false,
          description: "The Delivery Status Notification"
    field :email, Types::Email,
          null: false,
          description: "The email which was being delivered", method: :delivery
    field :extended_status, String,
          null: false,
          description: "An extended status description of the event"
    field :time, Types::DateTime,
          null: false,
          description: "Time of the event"
  end
end
