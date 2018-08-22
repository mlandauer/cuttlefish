class Types::AppType < Types::Base::Object
  description "An app in Cuttlefish"

  field :id, ID, null: false, description: "The database ID"
  field :name, String, null: true, description: "The name of the app"
  field :smtp_server, Types::SmtpServerType, null: false, description: "Details needed to send email to Cuttlefish for this app"
  field :cuttlefish, Boolean, null: false, description: "Whether this is the app used internally by cuttlefish for sending out its own emails"
  field :dkim_enabled, Boolean, null: false, description: "Whether DKIM is enabled for this app"
  field :legacy_dkim_selector, Boolean, null: false, description: "Whether this app is using the original form of the DNS record for DKIM"
  field :from_domain, String, null: true, description: "Domain that email in this domain is from. Required for DKIM."
  field :click_tracking_enabled, Boolean, null: false, description: "Whether click tracking is enabled for this app"
  field :open_tracking_enabled, Boolean, null: false, description: "Whether open tracking is enabled for this app"
  field :custom_tracking_domain, String, null: true, description: "Optional domain used for open and click tracking"
  field :permissions, Types::AppPermissionsType, null: false, description: "Permissions for current admin for accessing and editing this App" do
    # Permissions should be always accessible even on apps that you can't show
    guard ->(obj, args, ctx) { true }
  end

  guard ->(object, args, context) {
    AppPolicy.new(context[:current_admin], object.object).show?
  }

  def smtp_server
    {
      hostname: Rails.configuration.cuttlefish_domain,
      port: Rails.configuration.cuttlefish_smtp_port,
      username: object.smtp_username,
      password: object.smtp_password
     }
  end

  def permissions
    AppPolicy.new(context[:current_admin], object)
  end
end
