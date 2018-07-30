require "graphql/client"
require "graphql/client/http"

module Cuttlefish::ApiClient
  HTTP = GraphQL::Client::HTTP.new("http://localhost:5400/graphql") do
    def headers(context)
      { "Authorization": context[:api_key] }
    end
  end

  SCHEMA = GraphQL::Client.load_schema(HTTP)

  CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)

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
end
