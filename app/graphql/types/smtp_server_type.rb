class Types::SmtpServerType < Types::Base::Object
  description "Details needed to send email to the Cuttlefish SMTP server"
  field :hostname, String, null: false, description: "The hostname"
  field :port, Int, null: false, description: "The port"
  field :username, String, null: false, description: "The username to authenticate"
  field :password, String, null: false, description: "The password to authenticate"
end
