# frozen_string_literal: true

module WebhookServices
  class PostDeliveryEvent < ApplicationService
    def initialize(url:, key:, event:)
      super()
      @url = url
      @key = key
      @event = event
    end

    def call
      # For the time being just hardcode the serialisation format here
      meta_values = Hash[event.delivery.meta_values.map { |v| [v.key, v.value] }]
      email = {
        id: event.delivery.id,
        message_id: event.delivery.message_id,
        from: event.delivery.from,
        to: event.delivery.to,
        subject: event.delivery.subject,
        created_at: event.delivery.created_at.utc,
        meta_values: meta_values
      }
      delivery_event = {
        time: event.time.utc,
        dsn: event.dsn,
        status: event.status,
        extended_status: event.extended_status,
        email: email
      }
      data = {
        key: key,
        delivery_event: delivery_event
      }
      RestClient.post(url, data.to_json, content_type: :json)
    end

    private

    attr_reader :url, :key, :event
  end
end
