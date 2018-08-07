# TODO: ClickEvent and OpenEvent should inherit from the same interface

class Types::ClickEventType < Types::BaseObject
  description "Information about someone clicking on a link in an email"
  field :created_at, Types::DateTimeType, null: true, description: "When the click happened"
  field :url, String, null: false, description: "The URL of the link"
  field :user_agent, Types::FamilyAndVersionType, null: true, description: "Information about the browser/mail reader"
  def user_agent
    { family: object.calculate_ua_family, version: object.calculate_ua_version }
  end
  field :os, Types::FamilyAndVersionType, null: true, description: "The operating system the person was using"
  def os
    { family: object.calculate_os_family, version: object.calculate_os_version }
  end
  field :ip, String, null: true, description: "The IP address the click originated from"
end
