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
        deliveryEvents {
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
    query($appId: ID, $status: Status, $limit: Int, $offset: Int) {
      emails(appId: $appId, status: $status, limit: $limit, offset: $offset) {
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
        id
        name
      }
    }
  GRAPHQL

  DOCUMENTATION_QUERY = CLIENT.parse <<-'GRAPHQL'
    {
      apps {
        id
        name
        smtpServer {
          hostname
          port
          username
          password
        }
      }
    }
  GRAPHQL

  STATUS_COUNTS_QUERY = CLIENT.parse <<-'GRAPHQL'
    query ($since1: DateTime!, $since2: DateTime!) {
      emails1: emails(since: $since1) {
        ...statistics
      }
      emails2: emails(since: $since2) {
        ...statistics
      }
    }

    fragment statistics on EmailConnection {
      statistics {
        totalCount
        deliveredCount
        softBounceCount
        hardBounceCount
        notSentCount
        openRate
        clickRate
      }
    }
  GRAPHQL

  ADDRESSES_FROM_QUERY = CLIENT.parse <<-'GRAPHQL'
    query ($from: String!, $limit: Int, $offset: Int) {
      emails(from: $from, limit: $limit, offset: $offset) {
        totalCount
        statistics {
          totalCount
          deliveredCount
          softBounceCount
          hardBounceCount
          notSentCount
          openRate
          clickRate
        }
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
    }
  GRAPHQL

  ADMINS_QUERY = CLIENT.parse <<-'GRAPHQL'
    {
      admins {
        name
        email
        displayName
        invitationCreatedAt
        invitationAcceptedAt
        currentAdmin
      }
    }
  GRAPHQL

  APPS_INDEX_QUERY = CLIENT.parse <<-'GRAPHQL'
    {
      apps {
        id
        name
      }
    }
  GRAPHQL

  def self.query(q, variables:, current_admin:)
    result = CLIENT.query(
      q,
      variables: variables,
      context: LOCAL_API ?
        { current_admin: current_admin } :  { api_key: current_admin.api_key }
    )
    raise result.errors.messages["data"].join(", ") unless result.errors.empty?
    result
  end
end
