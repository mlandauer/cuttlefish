# frozen_string_literal: true

module Mutations
  class RemoveApp < Mutations::Base
    # TODO: Give descriptions for arguments and fields
    argument :id, ID, required: true

    field :errors, [Types::UserError], null: false

    def resolve(id:)
      AppServices::Destroy.call(
        id: id, current_admin: context[:current_admin]
      )

      { errors: [] }
    end
  end
end
