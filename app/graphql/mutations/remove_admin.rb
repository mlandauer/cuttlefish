# frozen_string_literal: true

module Mutations
  class RemoveAdmin < Mutations::Base
    # TODO: Give descriptions for arguments and fields
    argument :id, ID, required: true

    field :admin, Types::Admin, null: true

    def resolve(id:)
      begin
        remove_admin = AdminServices::Destroy.call(
          id: id, current_admin: context[:current_admin]
        )
      rescue Pundit::NotAuthorizedError
        raise GraphQL::ExecutionError.new(
          "Not authorized to remove this Admin",
          extensions: { "type" => "NOT_AUTHORIZED" }
        )
      end
      { admin: remove_admin.result }
    end
  end
end
