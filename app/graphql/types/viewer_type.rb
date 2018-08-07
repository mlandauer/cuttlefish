class Types::ViewerType < Types::BaseObject
  description "The currently authenticated admin"
  field :email, String, null: false, description: "Their email address"
  field :name, String, null: true, description: "Their full name"
end
