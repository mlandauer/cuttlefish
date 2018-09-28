class Mutations::CreateApp < GraphQL::Schema::Mutation
  argument :attributes, Types::AppAttributes, required: true

  field :app, Types::App, null: true
  field :errors, [Types::UserError], null: false

  def resolve(attributes:)
    # Handle default values
    open_tracking_enabled = attributes.open_tracking_enabled
    open_tracking_enabled = true if open_tracking_enabled.nil?
    click_tracking_enabled = attributes.click_tracking_enabled
    click_tracking_enabled = true if click_tracking_enabled.nil?

    create_app = ::CreateApp.call(
      current_admin: context[:current_admin],
      name: attributes.name,
      open_tracking_enabled: open_tracking_enabled,
      click_tracking_enabled: click_tracking_enabled,
      custom_tracking_domain: attributes.custom_tracking_domain
    )
    if create_app.success?
      { app: create_app.result, errors: [] }
    else
      if create_app.result
        user_errors = []
        # Convert Rails model errors into GraphQL-ready error hashes
        create_app.result.errors.keys.each do |attribute|
          m = create_app.result.errors.messages[attribute]
          d = create_app.result.errors.details[attribute]
          m.zip(d).each do |message, detail|
            # This is the GraphQL argument which corresponds to the validation error:
            path = ["attributes", attribute.to_s.camelize(:lower)]
            user_errors << {
              path: path,
              message: message,
              type: detail[:error].to_s.upcase
            }
          end
        end
      else
        user_errors = [{
          path: [],
          message: create_app.error,
          type: create_app.error_type.to_s.upcase
        }]
      end
      { app: nil, errors: user_errors}
    end
  end
end
