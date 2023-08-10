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
      argument :from, String,
               required: false,
               description: "Filter results by Email from address"
      argument :limit, Int,
               required: false,
               description:
                "For pagination: sets maximum number of items returned"
      argument :meta_key, String,
               required: false,
               description: "Filter results by Emails with given metadata key"
      argument :meta_value, String,
               required: false,
               description: "Filter results by Emails with given metadata value"
      argument :offset, Int,
               required: false,
               description: "For pagination: sets offset"
      argument :since, Types::DateTime,
               required: false,
               description: "Filter result to emails created since time"
      argument :status, Types::Status,
               required: false,
               description: "Filter results by Email status"
      argument :to, String,
               required: false,
               description: "Filter results by Email to address"
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
      # We should be able to access this without being authenticated
      guard ->(_obj, _args, _ctx) { true }
    end

    field :admins, [Types::Admin], null: false do
      description "List of Admins that this admin has access to, " \
                  "sorted alphabetically by name."
    end

    field :blocked_address, Types::BlockedAddress, null: true do
      argument :address, String, required: true, description: "Email address"
      argument :app_id, ID,
               required: true,
               description: "App"
      description "Find whether an email address is being blocked by a particular App"
    end

    # TODO: Switch over to more relay-like pagination
    field :blocked_addresses, Types::BlockedAddressConnection,
          connection: false, null: false do
      description "Auto-populated list of email addresses which bounced " \
                  "within the last week. Further emails to these addresses " \
                  "will be 'held back' and not sent"
      argument :address, String,
               required: false,
               description: "Filter results by email address"
      argument :app_id, ID,
               required: false,
               description: "Filter results by App"
      argument :dsn, String,
               required: false,
               description: "Filter results by type of delivery problem (of the form 5.x.x)"
      argument :limit, Int,
               required: false,
               description:
                "For pagination: sets maximum number of items returned"
      argument :offset, Int,
               required: false,
               description: "For pagination: sets offset"
    end

    field :dnsbl, [Types::DNSBL], null: false do
      description "Queries DNS for whether this server is on any known deny lists"
    end

    field :viewer, Types::Admin, null: true do
      description "The currently authenticated admin"
    end

    guard(lambda do |_object, _args, context|
      # We always need to be authenticated
      !context[:current_admin].nil?
    end)

    def email(id:)
      # When looking at the values of an email that's when won't be allowed if this
      # is an email we don't have access to
      email = Delivery.find_by(id: id)
      if email.nil?
        raise GraphQL::ExecutionError.new(
          "Email doesn't exist",
          extensions: { "type" => "NOT_FOUND" }
        )
      end
      email
    end

    # TODO: Switch over to more relay-like pagination
    def emails(
      app_id: nil, status: nil, since: nil, from: nil, to: nil,
      meta_key: nil, meta_value: nil,
      limit: 10, offset: 0
    )
      emails = Pundit.policy_scope(context[:current_admin], Delivery)
      emails = emails.where(app_id: app_id) if app_id
      emails = emails.where(status: status) if status
      emails = emails.where("deliveries.created_at > ?", since) if since
      emails = emails.joins(email: :meta_values).where(meta_values: { key: meta_key }) if meta_key
      emails = emails.joins(email: :meta_values).where(meta_values: { value: meta_value }) if meta_value
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

    def app(id:)
      # When looking at the values of an app that's when won't be allowed if this
      # is an app we don't have access to
      app = ::App.find_by(id: id)
      if app.nil?
        raise GraphQL::ExecutionError.new(
          "App doesn't exist",
          extensions: { "type" => "NOT_FOUND" }
        )
      end
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
      # When looking at the values of an app that's when won't be allowed if this
      # is an app we don't have access to
      ::App.cuttlefish
    end

    # This is accessible by ANY logged in admin so it's important that
    # nothing sensitive is exposed here
    def configuration
      Rails.configuration
    end

    def admins
      Pundit.policy_scope(context[:current_admin], ::Admin).order(:name)
    end

    def blocked_address(app_id:, address:)
      a = Address.find_by(text: address)
      return if a.nil?

      Pundit.policy_scope(context[:current_admin], DenyList)
            .where(address: a, app_id: app_id).first
    end

    def blocked_addresses(app_id: nil, address: nil, dsn: nil, limit: 10, offset: 0)
      b = Pundit.policy_scope(context[:current_admin], DenyList)
      b = b.where(app_id: app_id) if app_id
      if address
        a = Address.find_by(text: address)
        b = b.where(address: a)
      end
      b = b.joins(:caused_by_postfix_log_line).where(postfix_log_lines: { dsn: dsn }) if dsn
      b = b.order(created_at: :desc)
      { all: b, limit: limit, offset: offset }
    end

    def dnsbl
      # TODO: Check authorization. Currently we're allowing any logged in admin
      # to access this
      ::DNSBL::Client.new.lookup(Reputation.local_ip)
    end

    def viewer
      context[:current_admin]
    end
  end
end
