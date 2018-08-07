class Types::AppType < Types::BaseObject
  description "An app in Cuttlefish"
  field :id, ID, null: false, description: "The database ID"
  field :name, String, null: true, description: "The name of the app"
  field :smtp_server, Types::SmtpServerType, null: false, description: "Details needed to send email to Cuttlefish for this app"
  def smtp_server
    {
      hostname: Rails.configuration.cuttlefish_domain,
      port: Rails.configuration.cuttlefish_smtp_port,
      username: object.smtp_username,
      password: object.smtp_password
     }
  end
end
