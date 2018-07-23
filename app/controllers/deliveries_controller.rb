require "graphql/client"
require "graphql/client/http"

class DeliveriesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  def index
    @deliveries = policy_scope(Delivery)

    if params[:search]
      @search = params[:search]
      @deliveries = @deliveries.joins(:address).where("addresses.text" => @search)
    else
      @status = params[:status]
      if params[:app_id]
        @app = App.find(params[:app_id])
        @deliveries = @deliveries.where(app_id: @app.id)
        @deliveries = @deliveries.joins(:email).where("emails.app_id" => @app.id)
      end
      @deliveries = @deliveries.where(status: @status) if @status
    end

    @deliveries = @deliveries.includes(:delivery_links, :postfix_log_lines, :email, :address).order("deliveries.created_at DESC").page(params[:page])
  end

  HTTP = GraphQL::Client::HTTP.new("http://localhost:5400/graphql") do
    def headers(context)
      # Optionally set any HTTP headers
      { "Authorization": context[:api_key] }
    end
  end
  SCHEMA = GraphQL::Client.load_schema(HTTP)
  CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)
  EMAIL_QUERY = CLIENT.parse <<-'GRAPHQL'
    query($id: ID!) {
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

  def show
    result = CLIENT.query(
      EMAIL_QUERY,
      variables: {id: params[:id]},
      context: { api_key: current_admin.api_key }
    )
    @delivery = result.data.email
  end
end
