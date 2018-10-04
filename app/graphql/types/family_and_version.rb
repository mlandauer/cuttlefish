# frozen_string_literal: true

module Types
  class FamilyAndVersion < GraphQL::Schema::Object
    field :family, String, null: true
    field :version, String, null: true
  end
end
