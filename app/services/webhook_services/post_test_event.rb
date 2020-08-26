# frozen_string_literal: true

module WebhookServices
  class PostTestEvent < ApplicationService
    def initialize(url:, key:)
      super()
      @url = url
      @key = key
    end

    def call
      RestClient.post(
        url,
        { key: key, test_event: {} }.to_json,
        { content_type: :json }
      )
    end

    private

    attr_reader :url, :key
  end
end
