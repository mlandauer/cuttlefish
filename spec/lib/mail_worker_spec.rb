require "spec_helper"
require "ostruct"

describe MailWorker, '#perform' do
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
    MailWorker.new.perform(["<foo@bar.com>"], Base64.encode64(mail.encoded), app.id)

    expect(Email.count).to eq 1
  end

  it "should forward the email information" do
    expect_any_instance_of(OutgoingDelivery).to receive(:send)

    MailWorker.new.perform(["<foo@bar.com>"], Base64.encode64(mail.encoded), app.id)
  end

  it "should not save the email information if the forwarding fails" do
    allow_any_instance_of(OutgoingDelivery).to receive(:send).and_raise("I can't contact the mail server")

    expect {
      MailWorker.new.perform(["<foo@bar.com>"], Base64.encode64(mail.encoded), app.id)
    }.to raise_error("I can't contact the mail server")

    expect(Email.count).to eq 0
  end

  it "should discard the return path email and use the email contents as the from address" do
    expect_any_instance_of(OutgoingDelivery).to receive(:send)
    expect(Email).to receive(:create!).with(from: "matthew@foo.com", to: ["foo@bar.com"], data: mail.encoded, app_id: app.id).and_call_original

    MailWorker.new.perform(["<foo@bar.com>"], Base64.encode64(mail.encoded), app.id)
  end
end
