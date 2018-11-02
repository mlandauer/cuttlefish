# frozen_string_literal: true

module Mutations
  class UpgradeAppDkim < Mutations::Base
    argument :id,
             ID,
             required: true,
             description: "The app database ID to upgrade the dkim selector"

    field :app, Types::App, null: true

    def resolve(id:)
      upgrade_dkim = AppServices::UpgradeDkim.call(
        current_admin: current_admin, id: id
      )
      { app: upgrade_dkim.result }
    end
  end
end
