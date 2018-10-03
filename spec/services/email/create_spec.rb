# frozen_string_literal: true

require 'spec_helper'

describe Email::Create do
  # let(:app) { team.apps.create!(name: "Test") }
  let(:app) { create(:app) }
  let(:create_email) {
    Email::Create.(
      from: "contact@cuttlefish.io",
      to: "matthew@openaustralia.org",
      cc: nil,
      subject: "Test",
      text_part: "Hello. How are you?",
      html_part: "<p>Hello. How are you?</p>",
      app_id: app.id
    )
  }

  it "should send a test email" do
    expect(MailWorker).to receive(:perform_async)
    create_email
  end

  it "should create an email" do
    expect { create_email }.to change { Email.count }.by(1)
  end

  it "should return the service object" do
    expect(create_email).to be_a(Email::Create)
  end

  it "should return an email" do
    expect(create_email.result).to be_an(Email)
  end

  it "should not be possible to write to the result" do
    expect {
      create_email.result = nil
    }.to raise_error(NoMethodError)
  end
end
