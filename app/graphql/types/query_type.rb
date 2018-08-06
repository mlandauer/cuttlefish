class Types::QueryType < Types::BaseObject
  # Add root-level fields here.
  # They will be entry points for queries on your schema.
  description "The query root for the Cuttlefish GraphQL API"

  guard ->(object, args, context) {
    # We always need to be authenticated
    !context[:current_admin].nil?
  }

  field :email, Types::EmailType, null: true do
    argument :id, ID, required: true
    description "A single email"
  end

  def email(id:)
    email = Delivery.find_by(id: id)
    raise GraphQL::ExecutionError, "Email doesn't exist" if email.nil?
    email
  end

  field :emails, Types::EmailConnectionType, connection: false, null: true do
    argument :app_id, ID, required: false
    argument :status, Types::StatusType, required: false
    argument :limit, Int, required: false
    argument :offset, Int, required: false
    description "All emails. Most recent emails come first."
  end

  # TODO: Limit number of items in a page
  # TODO: Switch over to more relay-like pagination
  def emails(app_id: nil, status: nil, limit: 10, offset: 0)
    r = Pundit.policy_scope(context[:current_admin], Delivery)
    r = r.where(app_id: app_id) if app_id
    r = r.where(status: status) if status
    r = r.order("created_at DESC")
    { nodes: r.offset(offset).limit(limit), total_count: r.count }
  end

  field :apps, Types::AppConnectionType, connection: false, null: true do
    argument :limit, Int, required: false
    argument :offset, Int, required: false
    description "All apps"
  end

  # TODO: Limit number of items in a page
  # TODO: Switch over to more relay-like pagination
  def apps(limit: 10, offset: 0)
    r = Pundit.policy_scope(context[:current_admin], App).order(:name)
    { nodes: r.offset(offset).limit(limit), total_count: r.count }
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
