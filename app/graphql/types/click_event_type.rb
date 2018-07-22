# TODO: ClickEvent and OpenEvent should inherit from the same interface

class Types::ClickEventType < Types::BaseObject
  field :created_at, Types::DateTimeType, null: true
  field :url, String, null: false
  field :user_agent, Types::FamilyAndVersionType, null: true
  def user_agent
    { family: object.calculate_ua_family, version: object.calculate_ua_version }
  end
  field :os, Types::FamilyAndVersionType, null: true
  def os
    { family: object.calculate_os_family, version: object.calculate_os_version }
  end
  field :ip, String, null: true
end
