# frozen_string_literal: true

module Mutations
  class SendResetPasswordInstructions < Mutations::Base
    argument :email, String, required: true
    argument :reset_url, String, required: true

    # Clients of this mutation are unauthenticated. So we make sure
    # that we don't leak any information by returning anything useful here
    field :errors, [Types::UserError], null: false

    def resolve(email:, reset_url:)
      Admin.send_reset_password_instructions(
        { email: email },
        { reset_url: reset_url }
      )

      # Don't return anything useful
      { errors: [] }
    end
  end
end
