# frozen_string_literal: true

module Types
  class QueryType < GraphQL::Schema::Object
    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    description "The query root for the Cuttlefish GraphQL API"

    field :email, Types::Email, null: true do
      argument :id, ID, required: true, description: "ID of Email to find"
      description "Find a single Email"
    end

    field :emails, Types::EmailConnection, connection: false, null: true do
      description "A list of Emails that this admin has access to. " \
                  "Most recent emails come first."

      argument :app_id, ID,
               required: false,
               description: "Filter results by App"
      argument :status, Types::Status,
               required: false,
               description: "Filter results by Email status"
      argument :since, Types::DateTime,
               required: false,
               description: "Filter result to emails created since time"
      argument :from, String,
               required: false,
               description: "Filter results by Email from address"
      argument :to, String,
               required: false,
               description: "Filter results by Email to address"
      argument :limit, Int,
               required: false,
               description:
                "For pagination: sets maximum number of items returned"
      argument :offset, Int,
               required: false,
               description: "For pagination: sets offset"
    end

    field :app, Types::App, null: true do
      argument :id, ID, required: true, description: "ID of App to find"
      description "Find a single App"
    end

    field :apps, [Types::App], null: true do
      description "A list of Apps that this admin has access to, " \
                  "sorted alphabetically by name."
    end

    field :teams, [Types::Team], null: true do
      description "A list of all teams. Only accessible by a site admin."
    end

    field :cuttlefish_app, Types::App, null: false do
      description "The App used by Cuttlefish to send its own email"
    end

    field :configuration, Types::Configuration, null: false do
      description "Application configuration settings"
    end

    field :admins, [Types::Admin], null: false do
      description "List of Admins that this admin has access to, " \
                  "sorted alphabetically by name."
    end

    field :blocked_address, Types::BlockedAddress, null: true do
      argument :address, String, required: true, description: "Email address"
      description "Find whether an email address is being blocked"
    end

    # TODO: Switch over to more relay-like pagination
    field :blocked_addresses, Types::BlockedAddressConnection,
          connection: false, null: false do
      description "Auto-populated list of email addresses which bounced " \
                  "within the last week. Further emails to these addresses " \
                  "will be 'held back' and not sent"
      argument :limit, Int,
               required: false,
               description:
                "For pagination: sets maximum number of items returned"
      argument :offset, Int,
               required: false,
               description: "For pagination: sets offset"
    end

    field :viewer, Types::Admin, null: true do
      description "The currently authenticated admin"
    end

    guard(lambda do |_object, _args, context|
      # We always need to be authenticated
      !context[:current_admin].nil?
    end)

    def email(id:)
      email = Delivery.find_by(id: id)
      raise GraphQL::ExecutionError, "Email doesn't exist" if email.nil?

      email
    end

    # TODO: Switch over to more relay-like pagination
    def emails(
      app_id: nil, status: nil, since: nil, from: nil, to: nil,
      limit: 10, offset: 0
    )
      emails = Pundit.policy_scope(context[:current_admin], Delivery)
      emails = emails.where(app_id: app_id) if app_id
      emails = emails.where(status: status) if status
      emails = emails.where("deliveries.created_at > ?", since) if since
      if from
        address = Address.find_or_initialize_by(text: from)
        emails = emails.from_address(address)
      end
      if to
        address = Address.find_or_initialize_by(text: to)
        emails = emails.to_address(address)
      end
      emails = emails.order("created_at DESC")
      { all: emails, limit: limit, offset: offset }
    end

    # TODO: Generalise this to sensibly handling record not found exception
    def app(id:)
      app = ::App.find_by(id: id)
      raise GraphQL::ExecutionError, "App doesn't exist" if app.nil?

      app
    end

    def apps
      Pundit.policy_scope(context[:current_admin], ::App).order(:name)
    end

    def teams
      unless TeamPolicy.new(context[:current_admin], ::Team).index?
        raise GraphQL::ExecutionError.new(
          "Not authorized to access Query.teams",
          extensions: { "type" => "NOT_AUTHORIZED" }
        )
      end

      Pundit.policy_scope(context[:current_admin], ::Team)
    end

    def cuttlefish_app
      App.cuttlefish
    end

    def configuration
      Rails.configuration
    end

    def admins
      Pundit.policy_scope(context[:current_admin], Admin).order(:name)
    end

    def blocked_address(address:)
      a = Address.find_by(text: address)
      return if a.nil?

      Pundit.policy_scope(context[:current_admin], DenyList)
            .where(address: a).first
    end

    def blocked_addresses(limit: 10, offset: 0)
      b = Pundit.policy_scope(context[:current_admin], DenyList)
                .order(created_at: :desc)
      { all: b, limit: limit, offset: offset }
    end

    def viewer
      context[:current_admin]
    end
  end
end
