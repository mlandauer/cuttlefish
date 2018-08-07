class Types::ClickEventType < Types::BaseObject
  implements Types::UserAgentEventType

  description "Information about someone clicking on a link in an email"
  field :url, String, null: false, description: "The URL of the link"
end
