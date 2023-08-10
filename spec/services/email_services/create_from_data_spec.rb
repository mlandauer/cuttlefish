# frozen_string_literal: true

require "spec_helper"

describe EmailServices::CreateFromData do
  let(:from) { "bar@bar.com"}
  let(:to) { ["foo@foo.com"] }
  let(:data) { "From: #{from}\nSome email data" }
  let(:ignore_deny_list) { false }
  let(:app) { create(:app) }
  let(:service) do
    described_class.new(
      to: to,
      data: data,
      app_id: app.id,
      ignore_deny_list: ignore_deny_list,
      meta_values: {
        foo: "bar",
        bing: "bang"
      }
    )
  end

  it "#create" do
    email = service.create
    expect(email).to be_persisted
    expect(email.from).to eq from
    expect(email.to).to eq to
    expect(email.data).to eq data
    expect(email.app).to eq app
    expect(email.ignore_deny_list).to eq ignore_deny_list
    expect(email.meta_values.count).to eq 2
    expect(email.meta_values[0].key).to eq "bing"
    expect(email.meta_values[0].value).to eq "bang"
    expect(email.meta_values[1].key).to eq "foo"
    expect(email.meta_values[1].value).to eq "bar"
  end

  it "#send" do
    email = create(:email)
    expect(EmailServices::Send).to receive(:call).with(email: email)
    service.send(email)
  end
end
