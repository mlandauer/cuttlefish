# frozen_string_literal: true

module Mutations
  class UpdateApp < Mutations::Base
    argument :attributes, Types::AppAttributes, required: true
    argument :id, ID, required: true

    field :app, Types::App, null: true
    field :errors, [Types::UserError], null: false

    def resolve(id:, attributes:)
      update = AppServices::Update.call(
        current_admin: context[:current_admin],
        id: id,
        attributes: attributes.to_h
      )
      if update.success?
        user_errors = []
        { app: update.result, errors: user_errors }
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
        { app: nil, errors: user_errors }
      end
    end
  end
end
