# frozen_string_literal: true

module Mutations
  class AcceptAdminInvitation < Mutations::Base
    argument :name, String, required: false
    argument :password, String, required: true
    argument :token, String, required: true

    field :errors, [Types::UserError], null: false
    field :token, String, null: true

    def resolve(name:, password:, token:)
      Pundit.authorize(context[:current_admin], :invitation, :update?)
      admin = Admin.accept_invitation!(
        invitation_token: token,
        name: name,
        password: password
      )
      if admin.errors.empty?
        token = JWT.encode({ admin_id: admin.id, exp: Time.now.to_i + 3600 }, ENV["JWT_SECRET"], "HS512")
        { token: token, errors: [] }
      else
        { token: nil, errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
      end
    end
  end
end
