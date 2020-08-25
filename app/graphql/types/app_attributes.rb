# frozen_string_literal: true

module Types
  class AppAttributes < GraphQL::Schema::InputObject
    description "Attributes for creating or updating an app"
    argument :name,
             String,
             required: false,
             description: "The name of the app"
    argument :open_tracking_enabled,
             Boolean,
             required: false,
             description: "Whether tracking of email opens is enabled for " \
                          "this app. Defaults to true."
    argument :click_tracking_enabled,
             Boolean,
             required: false,
             description: "Whether tracking of email link clicks is enabled " \
                          "for this app. Defaults to true."
    argument :custom_tracking_domain,
             String,
             required: false,
             description: "Optional domain used for open and click tracking"
    argument :from_domain,
             String,
             required: false,
             description: "Domain that email in this domain is from. " \
                          "Required for DKIM."
    argument :dkim_enabled,
             Boolean,
             required: false,
             description: "Whether DKIM is enabled for this app. Requires " \
                          "DNS changes for the domain in fromDomain to be " \
                          "made before it can be enabled."
    argument :webhook_url,
             String,
             required: false,
             description: "If set, a POST is sent to the url for any delivery event " \
                          "associated with this app"
  end
end
