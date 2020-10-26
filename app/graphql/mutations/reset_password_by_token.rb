# frozen_string_literal: true

module Mutations
  class ResetPasswordByToken < Mutations::Base
    argument :password, String, required: true
    argument :token, String, required: true

    field :admin, Types::Admin, null: true
    field :errors, [Types::UserError], null: false

    def resolve(password:, token:)
      admin = Admin.reset_password_by_token(
        reset_password_token: token,
        password: password
      )

      { admin: admin, errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
    end
  end
end
