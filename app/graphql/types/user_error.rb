# frozen_string_literal: true

class Types::UserError < GraphQL::Schema::Object
  description "A user-readable error"

  field :message, String, null: false,
    description: "A description of the error"
  field :path, [String], null: true,
    description: "Which input value this error came from"
  # TODO: Make this an enum?
  field :type, String, null: false,
    description: "Type of error"
end
