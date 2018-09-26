require "graphql/client"
require "graphql/client/http"

module Cuttlefish::ApiClient
  # Temporarily force production to use graphql api directly rather than through http
  # LOCAL_API = !Rails.env.production?
  LOCAL_API = true

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

  DELIVERIES_SHOW = CLIENT.parse <<-'GRAPHQL'
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

  DELIVERIES_INDEX = CLIENT.parse <<-'GRAPHQL'
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

  DOCUMENTATION_INDEX = CLIENT.parse <<-'GRAPHQL'
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

  MAIN_STATUS_COUNTS = CLIENT.parse <<-'GRAPHQL'
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

  ADDRESSES_FROM = CLIENT.parse <<-'GRAPHQL'
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

  ADDRESSES_TO = CLIENT.parse <<-'GRAPHQL'
    query ($to: String!, $limit: Int, $offset: Int) {
      emails(to: $to, limit: $limit, offset: $offset) {
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
          from
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
      blockedAddress(address: $to) {
        id
        becauseOfDeliveryEvent {
          time
          extendedStatus
          email {
            id
          }
        }
        permissions {
          destroy
        }
      }
    }
  GRAPHQL

  ADMINS_INDEX = CLIENT.parse <<-'GRAPHQL'
    {
      admins {
        id
        name
        email
        displayName
        invitationCreatedAt
        invitationAcceptedAt
        currentAdmin
      }
    }
  GRAPHQL

  APPS_INDEX = CLIENT.parse <<-'GRAPHQL'
    {
      apps {
        id
        name
        dkimEnabled
        dkimDnsRecord {
          upgradeRequired
        }
      }
    }
  GRAPHQL

  APPS_SHOW = CLIENT.parse <<-'GRAPHQL'
    query($id: ID!) {
      app(id: $id) {
        id
        name
        cuttlefish
        dkimEnabled
        dkimDnsRecord {
          upgradeRequired
        }
        permissions {
          update
          dkim
        }
      }
    }
  GRAPHQL

  APPS_EDIT = CLIENT.parse <<-'GRAPHQL'
    query($id: ID!) {
      app(id: $id) {
        id
        name
        clickTrackingEnabled
        openTrackingEnabled
        customTrackingDomain
        permissions {
          destroy
        }
      }
    }
  GRAPHQL

  APPS_CREATE = CLIENT.parse <<-EOF
    mutation($name: String!, $clickTrackingEnabled: Boolean, $openTrackingEnabled: Boolean, $customTrackingDomain: String) {
      createApp(name: $name, clickTrackingEnabled: $clickTrackingEnabled, openTrackingEnabled: $openTrackingEnabled, customTrackingDomain: $customTrackingDomain) {
        app {
          id
          name
        }
        errors {
          message
          path
          type
        }
      }
    }
  EOF

  APPS_DKIM = CLIENT.parse <<-'GRAPHQL'
    query($id: ID!) {
      app(id: $id) {
        id
        fromDomain
        dkimDnsRecord {
          configured
          lookupValue
          targetValue
          name
        }
      }
    }
  GRAPHQL

  TEST_EMAILS_CREATE = CLIENT.parse <<-'GRAPHQL'
    mutation ($appId: ID!, $from: String!, $to: [String!]!, $subject: String!, $textPart: String, $htmlPart: String) {
      createEmails(appId: $appId, from: $from, to: $to, subject: $subject, textPart: $textPart, htmlPart: $htmlPart) {
        emails {
          id
        }
      }
    }
  GRAPHQL

  DENY_LISTS_INDEX = CLIENT.parse <<-'GRAPHQL'
    query($limit: Int, $offset: Int) {
      blockedAddresses(limit: $limit, offset: $offset) {
        totalCount
        nodes {
          id
          address
          becauseOfDeliveryEvent {
            extendedStatus
            time
            email {
              id
            }
          }
        }
      }
    }
  GRAPHQL

  ADMINS_DESTROY = CLIENT.parse <<-'GRAPHQL'
    mutation ($id: ID!) {
      removeAdmin(id: $id) {
        admin {
          displayName
        }
      }
    }
  GRAPHQL

  CLIENTS_INDEX = CLIENT.parse <<-'GRAPHQL'
    query($appId: ID) {
      emails(appId: $appId) {
        statistics {
          userAgentFamilyCounts {
            name
            count
          }
        }
      }
      apps {
        id
        name
      }
    }
  GRAPHQL

  DENY_LISTS_DESTROY = CLIENT.parse <<-'GRAPHQL'
    mutation($id: ID!) {
      removeBlockedAddress(id: $id) {
        blockedAddress {
          address
        }
      }
    }
  GRAPHQL

  TEAMS_INDEX = CLIENT.parse <<-EOF
    {
      teams {
        admins {
          email
          displayName
        }
        apps {
          id
          name
        }
      }
      cuttlefishApp {
        id
        name
      }
    }
  EOF

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
