# frozen_string_literal: true

module Mutations
  class AcceptAdminInvitation < Mutations::Base
    argument :name, String, required: false
    argument :password, String, required: true
    argument :token, String, required: true

    field :admin, Types::Admin, null: true
    field :errors, [Types::UserError], null: false

    def resolve(name:, password:, token:)
      Pundit.authorize(context[:current_admin], :invitation, :update?)
      admin = Admin.accept_invitation!(
        invitation_token: token,
        name: name,
        password: password
      )
      { admin: admin, errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
    end
  end
end
