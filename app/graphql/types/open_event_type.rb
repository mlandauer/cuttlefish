class Types::OpenEventType < Types::BaseObject
  field :created_at, Types::DateTimeType, null: true
  field :user_agent, Types::FamilyAndVersionType, null: true
  def user_agent
    { family: object.ua_family, version: object.ua_version }
  end
  field :os, Types::FamilyAndVersionType, null: true
  def os
    { family: object.os_family, version: object.os_version }
  end
  field :ip, String, null: true
end
