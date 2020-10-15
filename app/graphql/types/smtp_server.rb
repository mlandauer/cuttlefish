# frozen_string_literal: true

module Types
  class SmtpServer < GraphQL::Schema::Object
    description "Details needed to send email to the Cuttlefish SMTP server"
    field :hostname, String,
          null: false,
          description: "The hostname"
    field :port, Int,
          null: false,
          description: "The port"
    field :username, String,
          null: false,
          description: "The username to authenticate"
    field :password, String,
          null: false,
          description: "The password to authenticate"

    def hostname
      Rails.configuration.cuttlefish_smtp_host
    end

    def port
      Rails.configuration.cuttlefish_smtp_port
    end

    def username
      object.smtp_username
    end

    def password
      object.smtp_password
    end
  end
end
