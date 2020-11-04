# frozen_string_literal: true

module Types
  class DNSBL < GraphQL::Schema::Object
    field :dnsbl, String, null: false
    field :meaning, String, null: false
  end
end
