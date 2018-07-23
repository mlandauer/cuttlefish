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
      }
    }
  GRAPHQL
end
