require "spec_helper"

describe MailJob, '#perform' do
  it "should save the email information and forward it" do
    Email.any_instance.stub(:forward)
    MailJob.new(:from => "<matthew@foo.com>", :to => ["<foo@bar.com>"], :data => "message").perform

    Email.count.should == 1
  end

  it "should forward the email information" do
    email = mock_model(Email)
    email.should_receive(:forward)
    Email.stub(:create!).and_return(email)

    MailJob.new(:from => "<matthew@foo.com>", :to => ["<foo@bar.com>"], :data => "message").perform
  end

  it "should not save the email information if the forwarding fails" do
    Email.any_instance.stub(:forward).and_raise("I can't contact the mail server")

    expect {
      MailJob.new(:from => "<matthew@foo.com>", :to => ["<foo@bar.com>"], :data => "message").perform
    }.to raise_error
    
    Email.count.should == 0
  end

  it "should set the message-id based on the email content" do
    Email.any_instance.stub(:forward)
    MailJob.new(:from => "<matthew@foo.com>",
      :to => ["<foo@bar.com>"],
      :data => "From: contact@openaustraliafoundation.org.au\nTo: Matthew Landauer\nMessage-ID: <5161ba1c90b10_7837557029c754c8@kedumba.mail>\n\nHello!").perform

    Email.first.message_id.should == "5161ba1c90b10_7837557029c754c8@kedumba.mail"
  end
end