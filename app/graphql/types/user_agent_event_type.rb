module Types::UserAgentEventType
  include Types::Base::Interface
  description "An event initiated by someone from a browser / email client"
  field :created_at, Types::DateTimeType, null: true, description: "The time of the event"
  field :user_agent, Types::FamilyAndVersionType, null: true, description: "The browser / email client being used"
  def user_agent
    { family: object.calculate_ua_family, version: object.calculate_ua_version }
  end
  field :os, Types::FamilyAndVersionType, null: true, description: "The operating system being used"
  def os
    { family: object.calculate_os_family, version: object.calculate_os_version }
  end
  field :ip, String, null: true, description: "The originating IP address"
end
