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
    argument :since, Types::DateTimeType, required: false, description: "Filter result to emails created since time"
    argument :from, String, required: false, description: "Filter results by Email from address"
    argument :to, String, required: false, description: "Filter results by Email to address"
    argument :limit, Int, required: false, description: "For pagination: sets maximum number of items returned"
    argument :offset, Int, required: false, description: "For pagination: sets offset"
    description "A list of Emails that this admin has access to. Most recent emails come first."
  end

  # TODO: Switch over to more relay-like pagination
  def emails(app_id: nil, status: nil, since: nil, from: nil, to: nil, limit: 10, offset: 0)
    emails = Pundit.policy_scope(context[:current_admin], Delivery)
    emails = emails.where(app_id: app_id) if app_id
    emails = emails.where(status: status) if status
    emails = emails.where('deliveries.created_at > ?', since) if since
    if from
      emails = emails.from_address(Address.find_or_initialize_by(text: from))
    end
    if to
      emails = emails.to_address(Address.find_or_initialize_by(text: to))
    end
    { all: emails, order: "created_at DESC", limit: limit, offset: offset }
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
end
