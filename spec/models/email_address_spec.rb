require 'spec_helper'

describe EmailAddress do
  describe ".emails_sent" do
    it "should be able to find all the emails sent to this address" do
      email1 = Email.create!(:from => "matthew@foo.com")
      email2 = Email.create!(:from => "matthew@foo.com")
      email3 = Email.create!(:from => "peter@bar.com")

      EmailAddress.find_by_address("matthew@foo.com").emails_sent.should == [email1, email2]
    end
  end
end
