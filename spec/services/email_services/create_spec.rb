# frozen_string_literal: true

require "spec_helper"

describe EmailServices::Create do
  # let(:app) { team.apps.create!(name: "Test") }
  let(:app) { create(:app) }
  let(:create_email) do
    EmailServices::Create.call(
      from: "contact@cuttlefish.io",
      to: "matthew@openaustralia.org",
      cc: nil,
      subject: "Test",
      text_part: "Hello. How are you?",
      html_part: "<p>Hello. How are you?</p>",
      app_id: app.id,
      ignore_deny_list: false,
      meta_values: {}
    )
  end

  it "should send a test email" do
    expect_any_instance_of(EmailServices::CreateFromData).to receive(:call)
    create_email
  end

  it "should create an email" do
    allow(EmailServices::Send).to receive(:call)
    expect { create_email }.to change { Email.count }.by(1)
  end

  it "should return the service object" do
    allow(EmailServices::Send).to receive(:call)
    expect(create_email).to be_a(EmailServices::Create)
  end

  it "should return an email" do
    allow(EmailServices::Send).to receive(:call)
    expect(create_email.result).to be_an(Email)
  end

  it "should not be possible to write to the result" do
    allow(EmailServices::Send).to receive(:call)
    expect { create_email.result = nil }.to raise_error(NoMethodError)
  end
end
