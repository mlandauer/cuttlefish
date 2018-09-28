class Mutations::CreateApp < GraphQL::Schema::Mutation
  argument :attributes, Types::AppAttributes, required: true

  field :app, Types::App, null: true
  field :errors, [Types::UserError], null: false

  def user_errors_from_form_errors(errors, root_path)
    user_errors = []
    # Convert Rails model errors into GraphQL-ready error hashes
    errors.keys.each do |attribute|
      m = errors.messages[attribute]
      d = errors.details[attribute]
      m.zip(d).each do |message, detail|
        # This is the GraphQL argument which corresponds to the validation error:
        path = root_path + [attribute.to_s.camelize(:lower)]
        user_errors << {
          path: path,
          message: message,
          type: detail[:error].to_s.upcase
        }
      end
    end
    user_errors
  end

  def resolve(attributes:)
    # Handle default values
    open_tracking_enabled = attributes.open_tracking_enabled
    open_tracking_enabled = true if open_tracking_enabled.nil?
    click_tracking_enabled = attributes.click_tracking_enabled
    click_tracking_enabled = true if click_tracking_enabled.nil?

    create_app = App::Create.call(
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
        user_errors = user_errors_from_form_errors(
          create_app.result.errors,
          ["attributes"]
        )
      else
        user_errors = [{
          path: [],
          message: create_app.error.message,
          type: create_app.error.type.to_s.upcase
        }]
      end
      { app: nil, errors: user_errors}
    end
  end
end
