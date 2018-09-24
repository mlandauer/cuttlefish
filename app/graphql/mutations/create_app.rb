class Mutations::CreateApp < GraphQL::Schema::Mutation
  argument :name, String, required: true, description: "The name of the app"
  argument :open_tracking_enabled, Boolean, required: false,
    description: "Whether tracking of email opens is enabled for this app. Defaults to true."
  argument :click_tracking_enabled, Boolean, required: false,
    description: "Whether tracking of email link clicks is enabled for this app. Defaults to true."
  argument :custom_tracking_domain, String, required: false, description: "Optional domain used for open and click tracking"

  field :app, Types::App, null: true

  def resolve(
    name:,
    open_tracking_enabled: true,
    click_tracking_enabled: true,
    custom_tracking_domain: nil
  )
    create_app = ::CreateApp.call(
      current_admin: context[:current_admin],
      name: name,
      open_tracking_enabled: open_tracking_enabled,
      click_tracking_enabled: click_tracking_enabled,
      custom_tracking_domain: custom_tracking_domain
    )
    { app: create_app.result }
  end
end
