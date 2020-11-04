# frozen_string_literal: true

module Types
  # Don't return anything particularly sensitive here as this information
  # is available without authenticating
  class Configuration < GraphQL::Schema::Object
    description "Application configuration settings"
    field :max_no_emails_to_store, Int,
          null: false,
          description:
            "The maximum number of emails for which the full content is stored"
    field :domain, String,
          null: false,
          description: "The domain that this cuttlefish server is running on"
    field :fresh_install, Boolean,
          null: false,
          description: "Whether this is a completely new site installation and it has no current administrators"
    field :ip_address, String,
          null: false,
          description: "Public IPv4 address of server sending email"

    def domain
      object.cuttlefish_domain
    end

    def fresh_install
      ::Admin.first.nil?
    end

    def ip_address
      Reputation.local_ip
    end
  end
end
