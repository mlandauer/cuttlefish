# frozen_string_literal: true

module Types
  module UserAgentEvent
    include GraphQL::Schema::Interface
    description "An event initiated by someone from a browser / email client"
    field :created_at, Types::DateTime,
          null: true,
          description: "The time of the event"
    field :user_agent, Types::FamilyAndVersion,
          null: true,
          description: "The browser / email client being used"
    field :os, Types::FamilyAndVersion,
          null: true,
          description: "The operating system being used"
    field :ip, Types::IP,
          null: true,
          description: "The originating IP address and other information"

    def user_agent
      {
        family: object.calculate_ua_family,
        version: object.calculate_ua_version
      }
    end

    def os
      {
        family: object.calculate_os_family,
        version: object.calculate_os_version
      }
    end

    def ip
      { address: object.ip } if object.ip
    end
  end
end
