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
end