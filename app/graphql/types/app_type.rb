class Types::AppType < Types::BaseObject
  description "An app in Cuttlefish"

  field :id, ID, null: false, description: "The database ID"
  field :name, String, null: true, description: "The name of the app"
  field :smtp_server, Types::SmtpServerType, null: false, description: "Details needed to send email to Cuttlefish for this app"
  field :cuttlefish, Boolean, null: false, description: "Whether this is the app used internally by cuttlefish for sending out its own emails"
  field :dkim_enabled, Boolean, null: false, description: "Whether DKIM is enabled for this app"
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
