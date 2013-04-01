require 'spec_helper'

describe Email do
  describe ".from" do
    it "should return a string for the from email address" do
      email = Email.create!(:from_address => EmailAddress.create!(address: "matthew@foo.com"))
      email.from.should == "matthew@foo.com"
    end

    it "should allow the from_address to be set by a string" do
      email = Email.create!(:from => "matthew@foo.com")
      email.from.should == "matthew@foo.com"
    end
  end
end
