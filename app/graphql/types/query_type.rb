class Types::QueryType < Types::BaseObject
  # Add root-level fields here.
  # They will be entry points for queries on your schema.
  description "The query root for the Cuttlefish GraphQL API"

  field :email, Types::EmailType, null: true do
    argument :id, ID, required: true
    description "A single email"
  end

  def email(id:)
    email = Delivery.find_by(id: id)
    raise GraphQL::ExecutionError, "Email doesn't exist" if email.nil?
    email
  end

  field :emails, [Types::EmailType], null: true do
    argument :app_id, ID, required: false, default_value: nil
    description "All emails"
  end

  # TODO: Add pagination
  # TODO: Filter by sent/bounced etc..
  # TODO: Make sure that there aren't a bazillion db requests for a single query
  def emails(app_id:)
    unless context[:current_admin]
      raise GraphQL::ExecutionError, "Need to be authenticated"
    end
    r = Pundit.policy_scope(context[:current_admin], Delivery)
    r = r.where(app_id: app_id) if app_id
    r
  end

  field :configuration, Types::ConfigurationType, null: false do
    description "Application configuration settings"
  end

  def configuration
    Rails.configuration
  end

  field :viewer, Types::ViewerType, null: true do
    description "The currently authenticated admin"
  end

  def viewer
    context[:current_admin]
  end
end
