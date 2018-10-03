# frozen_string_literal: true

class Types::BlockedAddressPermissions < GraphQL::Schema::Object
  description "Permissions for current admin for accessing and editing a blocked address"

  field :destroy, Boolean, null: false, method: :destroy?
end
