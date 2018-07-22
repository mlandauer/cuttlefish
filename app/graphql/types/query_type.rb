class Types::QueryType < Types::BaseObject
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  # TODO: Add authentication
  # TODO: Add authorization
  field :email, Types::EmailType, null: false, description: "A single email" do
    argument :id, ID, required: true
  end

  def email(id:)
    Delivery.find(id)
  end

  field :emails, [Types::EmailType], null: true, description: "All emails"

  # TODO: Add pagination
  # TODO: Add authentication
  # TODO: Add authorization
  # TODO: Filter by app name
  # TODO: Filter by sent/bounced etc..
  def emails
    Delivery.all
  end

  field :configuration, Types::ConfigurationType, null: false
  def configuration
    Rails.configuration
  end
end
