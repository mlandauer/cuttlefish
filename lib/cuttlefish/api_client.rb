require "graphql/client"
require "graphql/client/http"

module Cuttlefish::ApiClient
  LOCAL_API = !Rails.env.production?

  if LOCAL_API
    CLIENT = GraphQL::Client.new(schema: CuttlefishSchema, execute: CuttlefishSchema)
  else
    HTTP = GraphQL::Client::HTTP.new("http://localhost:5400/graphql") do
      def headers(context)
        { "Authorization": context[:api_key] }
      end
    end

    SCHEMA = GraphQL::Client.load_schema(HTTP)
    CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)
  end

  EMAIL_QUERY = CLIENT.parse <<-'GRAPHQL'
    query($id: ID!) {
      configuration {
        maxNoEmailsToStore
      }
      email(id: $id) {
        from
        to
        subject
        content {
          html
          text
          source
        }
        createdAt
        status
        app {
          id
          name
        }
        opened
        clicked
        logs {
          time
          dsn
          extendedStatus
        }
        openEvents {
          ip
          userAgent {
            family
            version
          }
          os {
            family
            version
          }
          createdAt
        }
        clickEvents {
          url
          ip
          userAgent {
            family
            version
          }
          os {
            family
            version
          }
          createdAt
        }
      }
    }
  GRAPHQL

  EMAILS_QUERY = CLIENT.parse <<-'GRAPHQL'
    query($appId: ID, $status: Status, $first: Int, $skip: Int) {
      emails(appId: $appId, status: $status, first: $first, skip: $skip) {
        totalCount
        nodes {
          id
          to
          subject
          app {
            name
          }
          createdAt
          status
          opened
          clicked
        }
      }
      apps {
        nodes {
          id
          name
        }
      }
    }
  GRAPHQL

  def self.query(q, variables:, current_admin:)
    CLIENT.query(
      q,
      variables: variables,
      context: LOCAL_API ?
        { current_admin: current_admin } :  { api_key: current_admin.api_key }
    )
  end
end
