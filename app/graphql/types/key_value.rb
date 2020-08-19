# frozen_string_literal: true

module Types
  class KeyValue < GraphQL::Schema::Object
    description "A key/value pair"
    field :key, String,
          null: false
    field :value, String,
          null: false
  end
end
