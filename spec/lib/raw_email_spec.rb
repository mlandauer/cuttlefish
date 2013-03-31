require "spec_helper"

describe RawEmail do
  it "should record the email in the database" do
    email = RawEmail.new("matthew@foo.org", ["mlandauer@foo.org", "matthew@bar.com"], "This the main bit of the email")
    email.record

    saved = Email.first
    saved.from.should == "matthew@foo.org"
    saved.to.should == "mlandauer@foo.org, matthew@bar.com"
  end
end