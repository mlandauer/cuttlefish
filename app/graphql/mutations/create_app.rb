class Mutations::CreateApp < GraphQL::Schema::Mutation
  argument :name, String, required: true, description: "The name of the app"
  argument :open_tracking_enabled, Boolean, required: false,
    description: "Whether tracking of email opens is enabled for this app. Defaults to true."
  argument :click_tracking_enabled, Boolean, required: false,
    description: "Whether tracking of email link clicks is enabled for this app. Defaults to true."
  argument :custom_tracking_domain, String, required: false, description: "Optional domain used for open and click tracking"

  field :app, Types::App, null: true
  field :errors, [Types::UserError], null: false

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
    if create_app.success?
      { app: create_app.result, errors: [] }
    else
      if create_app.result
        # Convert Rails model errors into GraphQL-ready error hashes
        user_errors = create_app.result.errors.map do |attribute, message|
          # This is the GraphQL argument which corresponds to the validation error:
          path = ["attributes", attribute.to_s.camelize(:lower)]
          {
           path: path,
           message: message,
          }
        end
      else
        user_errors = [{ path: [], message: create_app.message}]
      end
      { app: nil, errors: user_errors}
    end
  end
end
