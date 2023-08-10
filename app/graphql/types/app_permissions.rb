# frozen_string_literal: true

module Types
  class AppPermissions < GraphQL::Schema::Object
    description "Permissions for current admin for accessing and editing an App"

    field :create, Boolean, null: false, method: :create?
    field :destroy, Boolean, null: false, method: :destroy?
    field :dkim, Boolean, null: false, method: :dkim?
    field :show, Boolean, null: false, method: :show?
    field :update, Boolean, null: false, method: :update?
  end
end
