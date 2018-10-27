# frozen_string_literal: true

module Mutations
  class RemoveApp < Mutations::Base
    # TODO: Give descriptions for arguments and fields
    argument :id, ID, required: true

    field :app, Types::App, null: true
    # TODO: Do we remove errors here?
    field :errors, [Types::UserError], null: false

    def resolve(id:)
      begin
        destroy = AppServices::Destroy.call(
          id: id, current_admin: context[:current_admin]
        )
      rescue Pundit::NotAuthorizedError
        raise GraphQL::ExecutionError.new(
          "Not authorized to remove this App",
          extensions: { "type" => "NOT_AUTHORIZED" }
        )
      end

      { app: destroy.result, errors: [] }
    end
  end
end
