class Types::AdminPermissions < GraphQL::Schema::Object
  description "Permissions for current admin for accessing and editing an Admin"

  field :destroy, Boolean, null: false, method: :destroy?
end
