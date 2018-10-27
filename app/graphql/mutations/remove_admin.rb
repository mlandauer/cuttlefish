# frozen_string_literal: true

module Mutations
  class RemoveAdmin < Mutations::Base
    # TODO: Give descriptions for arguments and fields
    argument :id, ID, required: true

    field :admin, Types::Admin, null: true

    def resolve(id:)
      remove_admin = AdminServices::Destroy.call(
        id: id, current_admin: context[:current_admin]
      )
      { admin: remove_admin.result }
    end
  end
end
