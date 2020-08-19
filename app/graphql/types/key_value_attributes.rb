# frozen_string_literal: true

module Types
  class KeyValueAttributes < GraphQL::Schema::InputObject
    description "Attributes of key, value pairs"
    argument :key,
             String,
             required: true
    argument :value,
             String,
             required: true
  end
end
