class Types::QueryType < Types::BaseObject
  # Add root-level fields here.
  # They will be entry points for queries on your schema.
  description "The query root for the Cuttlefish GraphQL API"

  guard ->(object, args, context) {
    # We always need to be authenticated
    !context[:current_admin].nil?
  }

  field :email, Types::EmailType, null: true do
    argument :id, ID, required: true, description: "ID of Email to find"
    description "Find a single Email"
  end

  def email(id:)
    email = Delivery.find_by(id: id)
    raise GraphQL::ExecutionError, "Email doesn't exist" if email.nil?
    email
  end

  field :emails, Types::EmailConnectionType, connection: false, null: true do
    argument :app_id, ID, required: false, description: "Filter results by App"
    argument :status, Types::StatusType, required: false, description: "Filter results by Email status"
    argument :limit, Int, required: false, description: "For pagination: sets maximum number of items returned"
    argument :offset, Int, required: false, description: "For pagination: sets offset"
    description "A list of Emails that this admin has access to. Most recent emails come first."
  end

  # TODO: Switch over to more relay-like pagination
  def emails(app_id: nil, status: nil, limit: 10, offset: 0)
    paginate(limit, offset) do
      r = Pundit.policy_scope(context[:current_admin], Delivery)
      r = r.where(app_id: app_id) if app_id
      r = r.where(status: status) if status
      r = r.order("created_at DESC")
      r
    end
  end

  field :apps, [Types::AppType], null: true do
    description "A list of Apps that this admin has access to, sorted alphabetically by name."
  end

  def apps
    Pundit.policy_scope(context[:current_admin], App).order(:name)
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

  private

  def paginate(limit, offset, &block)
    r = yield block
    { nodes: r.offset(offset).limit([limit, MAX_LIMIT].min), total_count: r.count }
  end

  # Limit can never be bigger than 50
  MAX_LIMIT = 50
end
