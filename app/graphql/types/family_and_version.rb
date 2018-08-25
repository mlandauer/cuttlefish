class Types::FamilyAndVersion < GraphQL::Schema::Object
  field :family, String, null: true
  field :version, String, null: true
end
