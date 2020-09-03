# frozen_string_literal: true

module Types
  class IP < GraphQL::Schema::Object
    field :address, String, null: false
  end
end
