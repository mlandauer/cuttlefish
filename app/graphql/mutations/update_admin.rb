# frozen_string_literal: true

module Mutations
  class UpdateAdmin < Mutations::Base
    argument :email, String, required: true
    argument :name, String, required: true
    argument :password, String, required: false
    argument :current_password, String, required: true

    field :errors, [Types::UserError], null: false

    def resolve(email:, name:, password: nil, current_password:)
      # We need to use a copy of the resource because we don't want to change
      # the current user in place.
      # TODO: Properly handle case of client not being logged in.
      admin = Admin.find(context[:current_admin].id)
      Pundit.authorize(admin, :registration, :update?)
      admin_updated = admin.update_with_password(
        email: email,
        name: name,
        password: password,
        current_password: current_password
      )
      if admin_updated
        { errors: [] }
      else
        { errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
      end
    end
  end
end
