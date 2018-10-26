# frozen_string_literal: true

class CuttlefishSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Guard.new(
    not_authorized: lambda do |type, field|
      GraphQL::ExecutionError.new(
        "Not authorized to access #{type}.#{field}",
        extensions: { "type" => "NOT_AUTHORIZED" }
      )
    end
  )
  use BatchLoader::GraphQL
end
