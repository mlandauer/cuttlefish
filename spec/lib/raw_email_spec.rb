require "spec_helper"

describe RawEmail do
  describe ".record" do
    before :each do
      email = RawEmail.new("matthew@foo.org", ["mlandauer@foo.org", "matthew@bar.com"], "This the main bit of the email")
      email.record
    end
    let(:saved) { Email.first }

    it "should record from address in the database" do
      saved.from.should == "matthew@foo.org"
      a1 = EmailAddress.find_by_address("matthew@foo.org")
      a1.should_not be_nil
      saved.from_address.should == a1
    end

    it "should record the to addresses in the database" do
      saved.to.should == "mlandauer@foo.org, matthew@bar.com"
    end
  end
end