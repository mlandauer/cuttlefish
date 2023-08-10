# frozen_string_literal: true

module Mutations
  class LoginAdmin < Mutations::Base
    argument :email, String, required: true
    argument :password, String, required: true

    field :admin, Types::Admin, null: true
    field :errors, [Types::UserError], null: false
    field :token, String, null: true

    def resolve(email:, password:)
      login_admin = AdminServices::Login.call(email: email, password: password)
      if login_admin.success?
        admin, token = login_admin.result
        { token: token, admin: admin, errors: [] }
      else
        { errors: [{ message: "Invalid email or password", type: "invalid" }] }
      end
    end
  end
end
