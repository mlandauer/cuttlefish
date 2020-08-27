# frozen_string_literal: true

module Types
  class App < GraphQL::Schema::Object
    description "An app in Cuttlefish"

    field :id, ID,
          null: false,
          description: "The database ID"
    field :name, String,
          null: true,
          description: "The name of the app"
    field :smtp_server, Types::SmtpServer,
          null: false,
          description: "Details needed to send email to Cuttlefish for this app"
    field :cuttlefish, Boolean,
          null: false,
          description: "Whether this is the app used internally by " \
                       "cuttlefish for sending out its own emails"
    field :dkim_enabled, Boolean,
          null: false,
          description: "Whether DKIM is enabled"
    field :dkim_dns_record, Types::DkimDnsRecord,
          null: false,
          description: "Information about this app's DKIM DNS record"
    field :from_domain, String,
          null: true,
          description:
            "Domain that email in this domain is from. Required for DKIM."
    field :click_tracking_enabled, Boolean,
          null: false,
          description: "Whether click tracking is enabled for this app"
    field :open_tracking_enabled, Boolean,
          null: false,
          description: "Whether open tracking is enabled for this app"
    field :custom_tracking_domain, String,
          null: true,
          description: "Optional domain used for open and click tracking"
    field :webhook_url, String,
          null: true,
          description: "If set, a POST is sent to the url for any delivery event " \
                       "associated with this app"
    field :webhook_key, String,
          null: false,
          description: "A secret key that is passed with every webhook POST. " \
                       "Used for authorization on the receiving end"
    field :permissions, Types::AppPermissions,
          null: false,
          description: "Permissions for current admin for accessing and " \
                       "editing this App" do
      # Permissions should be always accessible even on apps that you can't show
      guard ->(_obj, _args, _ctx) { true }
    end

    guard(lambda do |object, _args, context|
      AppPolicy.new(context[:current_admin], object.object).show?
    end)

    def smtp_server
      object
    end

    def dkim_dns_record
      object
    end

    def permissions
      AppPolicy.new(context[:current_admin], object)
    end
  end
end
