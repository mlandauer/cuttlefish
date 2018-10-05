# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Api
  # Temporarily force production to use graphql api directly rather than
  # through http
  # LOCAL_API = !Rails.env.production?
  LOCAL_API = true

  if LOCAL_API
    CLIENT = GraphQL::Client.new(
      schema: CuttlefishSchema,
      execute: CuttlefishSchema
    )
  else
    HTTP = GraphQL::Client::HTTP.new("http://localhost:5400/graphql") do
      def headers(context)
        { "Authorization": context[:api_key] }
      end
    end

    SCHEMA = GraphQL::Client.load_schema(HTTP)
    CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)
  end

  # Find all the graphql queries, parse them and populate constants
  # The graphql queries themselves are in lib/api
  module Queries
    Dir.glob("lib/api/**/*.graphql") do |f|
      m = f.match %r{/([^/]*)/([^/]*).graphql}
      const_set("#{m[1]}_#{m[2]}".upcase, CLIENT.parse(File.read(f)))
    end
  end

  # This is for making a query to a graphql api as a client
  def self.query(query, variables:, current_admin:)
    context = if LOCAL_API
                { current_admin: current_admin }
              else
                { api_key: current_admin.api_key }
              end
    result = CLIENT.query(
      query,
      variables: variables,
      context: context
    )

    raise result.errors.messages["data"].join(", ") unless result.errors.empty?

    result
  end
end
