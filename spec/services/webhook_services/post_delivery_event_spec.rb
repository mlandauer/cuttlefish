# frozen_string_literal: true

require "spec_helper"

describe WebhookServices::PostDeliveryEvent do
  it "should send a POST as json" do
    # Making all the values in factory explicit so that our
    # tests don't accidently become dependent on the implementation
    # of the factor
    from_address = create(:address, text: "foo@bar.com")
    to_address = create(:address, text: "bing@bar.com")
    email = create(
      :email,
      from_address: from_address
    )
    # Do this shenanigans to workaround callbacks on model
    email.update_columns(
      subject: "A lovely email",
      message_id: "ABC@DEF.foo.com"
    )
    create(:meta_value, email: email, key: "foo", value: "bar")
    create(:meta_value, email: email, key: "wibble", value: "wobble")
    delivery = create(
      :delivery,
      id: 123,
      email: email,
      address: to_address,
      created_at: Time.utc(2020, 1, 1, 10, 10, 10)
    )
    event = create(
      :postfix_log_line,
      time: Time.utc(2020, 1, 1, 20, 20, 20),
      dsn: "2.0.0",
      extended_status: "sent (250 ok dirdel)",
      delivery: delivery
    )
    expected_event = {
      time: "2020-01-01T20:20:20.000Z",
      dsn: "2.0.0",
      status: "delivered",
      extended_status: "sent (250 ok dirdel)",
      email: {
        id: 123,
        message_id: "ABC@DEF.foo.com",
        from: "foo@bar.com",
        to: "bing@bar.com",
        subject: "A lovely email",
        created_at: "2020-01-01T10:10:10.000Z",
        meta_values: {
          foo: "bar",
          wibble: "wobble"
        }
      }
    }
    expect(RestClient).to receive(:post).with(
      "https://foo.com",
      { key: "abc123", delivery_event: expected_event }.to_json,
      { content_type: :json }
    )
    WebhookServices::PostDeliveryEvent.call(
      url: "https://foo.com",
      key: "abc123",
      event: event
    )
  end
end
