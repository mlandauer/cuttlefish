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
  CLIENT.allow_dynamic_queries = true if Rails.env.development?

  # Find all the graphql queries, parse them and populate constants
  # The graphql queries themselves are in lib/api
  # In production loads all the queries into constants once while
  # in development reads the files on every query so that we don't
  # need to restart the server
  module Queries
    unless Rails.env.development?
      Dir.glob("lib/api/**/*.graphql") do |f|
        m = f.match %r{/([^/]*)/([^/]*).graphql}
        const_set("#{m[1]}_#{m[2]}".upcase, CLIENT.parse(File.read(f)))
      end
    end

    def self.get(controller_name, file_prefix)
      if Rails.env.development?
        CLIENT.parse(File.read("lib/api/#{controller_name}/#{file_prefix}.graphql"))
      else
        const_get("#{controller_name}_#{file_prefix}".upcase)
      end
    end
  end

  # This is for making a query to a graphql api as a client
  def self.query(query, variables:, jwt_token:)
    # Convert variable names to camelcase for graphql
    variables = variables.transform_keys { |k| k.to_s.camelize(:lower) }

    context = if LOCAL_API && jwt_token
                # Lookup admin from the token
                payload, _header = JWT.decode(jwt_token, ENV["JWT_SECRET"], true, { algorithm: "HS512" })
                { current_admin: Admin.find(payload["admin_id"]) }
              else
                {}
              end
    result = CLIENT.query(
      query,
      variables: variables,
      context: context
    )

    result.data.errors.details.each do |_path, details|
      details.each do |detail|
        case detail["extensions"]["type"]
        when "NOT_AUTHORIZED"
          raise Pundit::NotAuthorizedError, detail["message"]
        when "NOT_FOUND"
          raise ActiveRecord::RecordNotFound, detail["message"]
        end
      end
    end
    result
  end
end
