class Types::QueryType < Types::BaseObject
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :email, Types::EmailType, null: false, description: "An email"
  
  def email
    Delivery.first
  end

  # TODO: remove me
  field :test_field, String, null: false,
    description: "An example field added by the generator"
  def test_field
    "Hello World!"
  end
end
