class Types::AppType < Types::BaseObject
  description "An app in Cuttlefish"
  field :id, ID, null: false, description: "The database ID"
  field :name, String, null: true, description: "The name of the app"
end
