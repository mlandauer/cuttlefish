# frozen_string_literal: true

module Mutations
  class LoginAdmin < Mutations::Base
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :admin, Types::Admin, null: true
    field :errors, [Types::UserError], null: false

    def resolve(email:, password:)
      # For the time being just implement everything here
      # TODO: Move stuff to a service class
      admin = Admin.find_by(email: email)
      # TODO: Also do the hashing (and throw away the result) if admin is nil
      if admin&.valid_password?(password)
        # Token has expiry time of 1 hour
        exp = Time.now.to_i + 3600
        # Keeping the claims to an absolute minimum for the time being
        payload = { admin_id: admin.id, exp: exp }
        token = JWT.encode payload, ENV["JWT_SECRET"], "HS512"
        { token: token, admin: admin, errors: [] }
      else
        { errors: [{ message: "Invalid email or password", type: "invalid" }] }
      end
    end
  end
end
