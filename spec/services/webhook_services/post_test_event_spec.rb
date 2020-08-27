# frozen_string_literal: true

require "spec_helper"

describe WebhookServices::PostTestEvent do
  it "should send a POST as json" do
    expect(RestClient).to receive(:post).with(
      "https://foo.com",
      { key: "abc123", test_event: {} }.to_json,
      { content_type: :json }
    )
    WebhookServices::PostTestEvent.call(
      url: "https://foo.com",
      key: "abc123"
    )
  end
end
