require "spec_helper"

describe RawEmail do
  it "should record the email in the database" do
    email = RawEmail.new("matthew@foo.org", ["mlandauer@foo.org", "matthew@bar.com"], "This the main bit of the email")
    email.record

    saved = Email.first
    saved.from.should == "matthew@foo.org"
    a1 = EmailAddress.find_by_address("matthew@foo.org")
    a1.should_not be_nil
    saved.from_address.should == a1
    saved.to.should == "mlandauer@foo.org, matthew@bar.com"
  end
end