# frozen_string_literal: true

module Types
  class BlockedAddressPermissions < GraphQL::Schema::Object
    description "Permissions for current admin for accessing and editing a blocked address"

    field :destroy, Boolean, null: false, method: :destroy?
  end
end
