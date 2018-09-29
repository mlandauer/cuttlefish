class Mutations::UpdateApp < Mutations::Base
  argument :id, ID, required: true
  argument :attributes, Types::AppAttributes, required: true

  field :app, Types::App, null: true
  field :errors, [Types::UserError], null: false

  def resolve(id:, attributes:)
    update = App::Update.(
      current_admin: context[:current_admin],
      id: id,
      name: attributes.name,
      open_tracking_enabled: attributes.open_tracking_enabled,
      click_tracking_enabled: attributes.click_tracking_enabled,
      custom_tracking_domain: attributes.custom_tracking_domain,
      from_domain: attributes.from_domain
    )
    if update.success?
      { app: update.result, errors: [] }
    else
      user_errors = if update.result
        user_errors_from_form_errors(
          update.result.errors,
          ["attributes"]
        )
      else
        [{
          path: [],
          message: update.error.message,
          type: update.error.type.to_s.upcase
        }]
      end
      { app: nil, errors: user_errors}
    end
  end
end
