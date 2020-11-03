# frozen_string_literal: true

module Mutations
  class ResetPasswordByToken < Mutations::Base
    argument :password, String, required: true
    argument :token, String, required: true

    # Returns a JSON web token so the user has the option to automatically
    # log in after a password reset
    field :token, String, null: false
    field :errors, [Types::UserError], null: false

    def resolve(password:, token:)
      admin = Admin.reset_password_by_token(
        reset_password_token: token,
        password: password
      )
      token = JWT.encode({ admin_id: admin.id, exp: Time.now.to_i + 3600 }, ENV["JWT_SECRET"], "HS512")

      { token: token, errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
    end
  end
end
