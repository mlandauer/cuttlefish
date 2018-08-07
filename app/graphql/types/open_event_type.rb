class Types::OpenEventType < Types::BaseObject
  description "Information about someone opening an email"
  field :created_at, Types::DateTimeType, null: true, description: "When the email was opened"
  field :user_agent, Types::FamilyAndVersionType, null: true, description: "The browser / email client that was being used"
  def user_agent
    { family: object.ua_family, version: object.ua_version }
  end
  field :os, Types::FamilyAndVersionType, null: true, description: "The operating system that was being used at the time"
  def os
    { family: object.os_family, version: object.os_version }
  end
  field :ip, String, null: true, description: "The originating IP address"
end
