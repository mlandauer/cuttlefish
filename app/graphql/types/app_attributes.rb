class Types::AppAttributes < GraphQL::Schema::InputObject
  description "Attributes for creating or updating an app"
  argument :name, String, required: true, description: "The name of the app"
  argument :open_tracking_enabled, Boolean, required: false,
    description: "Whether tracking of email opens is enabled for this app. Defaults to true."
  argument :click_tracking_enabled, Boolean, required: false,
    description: "Whether tracking of email link clicks is enabled for this app. Defaults to true."
  argument :custom_tracking_domain, String, required: false, description: "Optional domain used for open and click tracking"
end
