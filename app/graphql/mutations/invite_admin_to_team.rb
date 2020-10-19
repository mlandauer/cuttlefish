# frozen_string_literal: true

module Mutations
  class InviteAdminToTeam < Mutations::Base
    argument :email, String, required: true
    argument :accept_url, String, required: true

    field :admin, Types::Admin, null: true
    field :errors, [Types::UserError], null: false

    def resolve(email:, accept_url:)
      Pundit.authorize(context[:current_admin], :invitation, :create?)
      admin = Admin.invite_to_team!(
        email: email,
        inviting_admin: context[:current_admin],
        accept_url: accept_url
      )
      { admin: admin, errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
    end
  end
end
