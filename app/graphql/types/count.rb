# frozen_string_literal: true

class Types::Count < GraphQL::Schema::Object
  description "A bucket to hold the number of times a particular thing happens"

  field :name, String, null: false, description: "The name of the thing that happens"
  field :count, Int, null: false, description: "The number of times the thing happens"
end
