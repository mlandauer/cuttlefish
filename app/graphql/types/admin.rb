# frozen_string_literal: true

module Types
  class Admin < GraphQL::Schema::Object
    description "An administrator"

    field :display_name, String,
          null: false,
          description: "The name if it's available, otherwise the email"
    field :email, String,
          null: false,
          description: "Their email address"
    field :id, ID,
          null: false,
          description: "The database ID"
    field :invitation_accepted_at, Types::DateTime,
          null: true,
          description: "When an invitation to this admin was accepted"
    field :invitation_created_at, Types::DateTime,
          null: true,
          description: "When an invitation to this admin was created"
    field :name, String,
          null: true,
          description: "Their full name"
    # TODO: Rename this to "current" to avoid confusion
    field :current_admin, Boolean,
          null: false,
          description: "Whether this is the current admin"
    field :site_admin, Boolean,
          null: false,
          description: "Whether this admin can administer the whole site", method: :site_admin?

    def current_admin
      context[:current_admin] == object
    end
  end
end
