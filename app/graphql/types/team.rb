# frozen_string_literal: true

module Types
  class Team < GraphQL::Schema::Object
    description "A team"

    field :admins, [Types::Admin], null: false do
      description "Admins that belong to this team, sorted alphabetically by name."
    end

    field :apps, [Types::App], null: true do
      description "Apps that belong to this team, sorted alphabetically by name."
    end

    def admins
      object.admins.order(:name)
    end

    def apps
      object.apps.order(:name)
    end
  end
end
