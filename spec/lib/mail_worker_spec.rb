# frozen_string_literal: true

require "spec_helper"
require "ostruct"

describe MailWorker, "#perform" do
  let(:team) { Team.create! }
  let(:app) { team.apps.create!(name: "test") }
  let(:mail) do
    Mail.new do
      subject "Hello!"
      from "Matthew Landauer <matthew@foo.com>"
      to "Some other place <foo@bar.com>"
      body "Let's say some stuff"
    end
  end
  let(:email) do
    Email.create!(
      to: ["foo@bar.com"],
      data: mail.encoded,
      app_id: app.id
    )
  end

  it "should forward the email information" do
    expect(EmailServices::Send).to receive(:call)

    MailWorker.new.perform(email.id)
  end
end
