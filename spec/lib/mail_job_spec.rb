require "spec_helper"
require "ostruct"

describe MailJob, '#perform' do
  let(:team) { Team.create! }
  let(:app) { team.apps.create!(name: "test") }
  let(:mail) {
    Mail.new do
      subject "Hello!"
      from "Matthew Landauer <matthew@foo.com>"
      to "Some other place <foo@bar.com>"
      body "Let's say some stuff"
    end
  }


  it "should save the email information and forward it" do
    allow_any_instance_of(OutgoingDelivery).to receive(:send)
    MailJob.new(OpenStruct.new(sender: "<matthew@foo.com>", recipients: ["<foo@bar.com>"], data: mail.encoded, app_id: app.id)).perform

    expect(Email.count).to eq 1
  end

  it "should forward the email information" do
    expect_any_instance_of(OutgoingDelivery).to receive(:send)

    MailJob.new(OpenStruct.new(sender: "<matthew@foo.com>", recipients: ["<foo@bar.com>"], data: mail.encoded, app_id: app.id)).perform
  end

  it "should not save the email information if the forwarding fails" do
    allow_any_instance_of(OutgoingDelivery).to receive(:send).and_raise("I can't contact the mail server")

    expect {
      MailJob.new(OpenStruct.new(sender: "<matthew@foo.com>", recipients: ["<foo@bar.com>"], data: "message", app_id: app.id)).perform
    }.to raise_error

    expect(Email.count).to eq 0
  end

  it "should discard the return path email and use the email contents as the from address" do
    expect_any_instance_of(OutgoingDelivery).to receive(:send)
    expect(Email).to receive(:create!).with(from: "matthew@foo.com", to: ["foo@bar.com"], data: mail.encoded, app_id: app.id).and_call_original

    MailJob.new(OpenStruct.new(sender: "<bounces@foo.com>", recipients: ["<foo@bar.com>"], data: mail.encoded, app_id: app.id)).perform
  end
end
