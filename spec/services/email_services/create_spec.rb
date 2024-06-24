# frozen_string_literal: true

require "spec_helper"

describe EmailServices::Create do
  # let(:app) { team.apps.create!(name: "Test") }
  let(:app) { create(:app) }
  let(:create_email) do
    described_class.call(
      from: "contact@cuttlefish.io",
      to: "matthew@openaustralia.org",
      cc: nil,
      subject: "Test",
      text_part: "Hello. How are you?",
      html_part: "<p>Hello. How are you?</p>",
      app_id: app.id,
      ignore_deny_list: false,
      disable_css_inlining: false,
      meta_values: {}
    )
  end

  it "sends a test email" do
    expect_any_instance_of(EmailServices::CreateFromData).to receive(:call)
    create_email
  end

  it "creates an email" do
    allow(EmailServices::Send).to receive(:call)
    expect { create_email }.to change(Email, :count).by(1)
  end

  it "returns the service object" do
    allow(EmailServices::Send).to receive(:call)
    expect(create_email).to be_a(described_class)
  end

  it "returns an email" do
    allow(EmailServices::Send).to receive(:call)
    expect(create_email.result).to be_an(Email)
  end

  it "is not possible to write to the result" do
    allow(EmailServices::Send).to receive(:call)
    expect { create_email.result = nil }.to raise_error(NoMethodError)
  end
end
