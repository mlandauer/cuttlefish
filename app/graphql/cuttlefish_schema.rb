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

GraphQL::Errors.configure(CuttlefishSchema) do
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    GraphQL::ExecutionError.new(
      "We couldn't find what you were looking for",
      extensions: { "type" => "NOT_FOUND" }
    )
  end
end
