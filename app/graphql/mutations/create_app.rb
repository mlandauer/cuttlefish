# frozen_string_literal: true

module Mutations
  class CreateApp < Mutations::Base
    argument :attributes, Types::AppAttributes, required: true

    field :app, Types::App, null: true
    field :errors, [Types::UserError], null: false

    def resolve(attributes:)
      # Handle default values
      open_tracking_enabled = attributes.open_tracking_enabled
      open_tracking_enabled = true if open_tracking_enabled.nil?
      click_tracking_enabled = attributes.click_tracking_enabled
      click_tracking_enabled = true if click_tracking_enabled.nil?
      dkim_enabled = attributes.dkim_enabled
      dkim_enabled = false if dkim_enabled.nil?

      begin
        create_app = AppServices::Create.call(
          current_admin: context[:current_admin],
          name: attributes.name,
          open_tracking_enabled: open_tracking_enabled,
          click_tracking_enabled: click_tracking_enabled,
          custom_tracking_domain: attributes.custom_tracking_domain,
          from_domain: attributes.from_domain,
          dkim_enabled: dkim_enabled
        )
        result = create_app.result
        success = create_app.success?
        error = create_app.error
        if success
          { app: result, errors: [] }
        else
          user_errors = if result
                          user_errors_from_form_errors(
                            result.errors,
                            ["attributes"]
                          )
                        else
                          [{
                            path: [],
                            message: error.message,
                            type: error.type.to_s.upcase
                          }]
                        end
          { app: nil, errors: user_errors }
        end
      rescue Pundit::NotAuthorizedError
        user_errors = [{
          path: [],
          message: "You don't have permissions to do this",
          type: "PERMISSION"
        }]
        { app: nil, errors: user_errors }
      end
    end
  end
end
