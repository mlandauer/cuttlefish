require 'spec_helper'

describe EmailAddress do
  describe "#emails_sent" do
    it "should be able to find all the emails sent from this address" do
      email1 = Email.create!(:from => "matthew@foo.com")
      email2 = Email.create!(:from => "matthew@foo.com")
      email3 = Email.create!(:from => "peter@bar.com")

      EmailAddress.find_by_address("matthew@foo.com").emails_sent.should == [email1, email2]
    end
  end

  describe "#emails_received" do
    it "should be able to find all the emails received by this address" do
      email1 = Email.create!(:to => "matthew@foo.com")
      email2 = Email.create!(:to => "matthew@foo.com")
      email3 = Email.create!(:to => "peter@bar.com")

      EmailAddress.find_by_address("matthew@foo.com").emails_received.should == [email1, email2]
    end
  end
end
