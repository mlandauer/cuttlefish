# frozen_string_literal: true

module Mutations
  class RemoveAdmin < Mutations::Base
    # TODO: Give descriptions for arguments and fields
    argument :id, ID, required: true

    # We want the errors for a non-existent id and one you don't have
    # permission to access to be the same so that there is no information
    # leakage to clients about which ids are being used.
    # Therefore, we might as well just return nil for the admin in these cases.
    # There is little need for fancy return error messages
    field :admin, Types::Admin, null: true

    def resolve(id:)
      begin
        remove_admin = AdminServices::Destroy.call(
          id: id, current_admin: context[:current_admin]
        )
      rescue ActiveRecord::RecordNotFound, Pundit::NotAuthorizedError
        raise GraphQL::ExecutionError.new(
          "Admin doesn't exist or you are not authorized",
          extensions: { "type" => "NOT_FOUND" }
        )
      end
      { admin: remove_admin.result }
    end
  end
end
