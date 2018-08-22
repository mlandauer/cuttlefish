class Types::AppType < Types::Base::Object
  description "An app in Cuttlefish"

  field :id, ID, null: false, description: "The database ID"
  field :name, String, null: true, description: "The name of the app"
  field :smtp_server, Types::SmtpServerType, null: false, description: "Details needed to send email to Cuttlefish for this app"
  field :cuttlefish, Boolean, null: false, description: "Whether this is the app used internally by cuttlefish for sending out its own emails"
  field :dkim, Types::DkimType, null: false, description: "Information about this app's DKIM setup"
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
    object
  end

  def dkim
    object
  end

  def permissions
    AppPolicy.new(context[:current_admin], object)
  end
end
