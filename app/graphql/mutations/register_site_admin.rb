# frozen_string_literal: true

module Mutations
  class RegisterSiteAdmin < Mutations::Base
    argument :name, String, required: false
    argument :email, String, required: true
    argument :password, String, required: true

    field :admin, Types::Admin, null: true
    field :errors, [Types::UserError], null: false

    def resolve(name: nil, email:, password:)
      Pundit.authorize(context[:current_admin], :registration, :create?)

      # TODO: Put these in a transaction
      team = Team.create!
      admin = Admin.new(
        name: name,
        email: email,
        password: password,
        team_id: team.id,
        site_admin: true
      )
      admin.save

      if admin.persisted?
        { admin: admin, errors: [] }
      else
        { admin: nil, errors: user_errors_from_form_errors(admin.errors, ["attributes"]) }
      end
    end
  end
end
