class Types::AppPermissionsType < Types::Base::Object
  description "Permissions for current admin for accessing and editing an App"

  field :show, Boolean, null: false, method: :show?
  field :create, Boolean, null: false, method: :create?
  field :update, Boolean, null: false, method: :update?
  field :destroy, Boolean, null: false, method: :destroy?
  field :dkim, Boolean, null: false, method: :dkim?
end
