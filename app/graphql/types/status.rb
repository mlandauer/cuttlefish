# frozen_string_literal: true

class Types::Status < GraphQL::Schema::Enum
  description "The delivery status of an email"
  value "not_sent", "Not sent because it's on the deny list"
  # TODO: Rename this to in_flight to be clearer
  value "sent", "Sent but not yet delivered or bounced"
  value "delivered", "Delivered to its destination"
  value "soft_bounce", "A temporary delivery problem"
  value "hard_bounce", "A permanent delivery problem"
end
