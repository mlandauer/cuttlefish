# frozen_string_literal: true

module Types
  class DeliveryEvent < GraphQL::Schema::Object
    description "Information about an attempt to deliver an email"
    field :time, Types::DateTime, null: false, description: "Time of the event"
    field :dsn, String, null: false, description: "The Delivery Status Notification"
    field :extended_status, String, null: false, description: "An extended status description of the event"
    field :email, Types::Email, null: false, description: "The email which was being delivered"

    def email
      object.delivery
    end
  end
end
