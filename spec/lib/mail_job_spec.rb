require "spec_helper"

describe MailJob, '#perform' do
  it "should save the email information and forward it" do
    Email.any_instance.stub(:forward)
    MailJob.new(OpenStruct.new(:sender => "<matthew@foo.com>", :recipients => ["<foo@bar.com>"], :data => "message")).perform

    Email.count.should == 1
  end

  it "should forward the email information to port 25 on the localhost" do
    email = mock_model(Email)
    email.should_receive(:forward).with("localhost", 25)
    Email.stub(:create!).and_return(email)

    MailJob.new(OpenStruct.new(:sender => "<matthew@foo.com>", :recipients => ["<foo@bar.com>"], :data => "message")).perform
  end

  it "should not save the email information if the forwarding fails" do
    Email.any_instance.stub(:forward).and_raise("I can't contact the mail server")

    expect {
      MailJob.new(OpenStruct.new(:sender => "<matthew@foo.com>", :recipients => ["<foo@bar.com>"], :data => "message")).perform
    }.to raise_error
    
    Email.count.should == 0
  end
end