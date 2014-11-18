require "spec_helper"
require "ostruct"

describe MailJob, '#perform' do
  let(:app) { App.create(name: "test") }

  it "should save the email information and forward it" do
    OutgoingEmail.any_instance.stub(:send)
    MailJob.new(OpenStruct.new(sender: "<matthew@foo.com>", recipients: ["<foo@bar.com>"], data: "message", app_id: app.id)).perform

    Email.count.should == 1
  end

  it "should forward the email information" do
    OutgoingEmail.any_instance.should_receive(:send)

    MailJob.new(OpenStruct.new(sender: "<matthew@foo.com>", recipients: ["<foo@bar.com>"], data: "message", app_id: app.id)).perform
  end

  it "should not save the email information if the forwarding fails" do
    Email.any_instance.stub(:forward).and_raise("I can't contact the mail server")

    expect {
      MailJob.new(OpenStruct.new(sender: "<matthew@foo.com>", recipients: ["<foo@bar.com>"], data: "message", app_id: app.id)).perform
    }.to raise_error

    Email.count.should == 0
  end
end
