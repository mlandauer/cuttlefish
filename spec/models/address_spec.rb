require 'spec_helper'

describe Address do
  context "three emails" do
    let (:address1) { Address.create!(text: "matthew@foo.com") }
    let (:address2) { Address.create!(text: "peter@bar.com") }
    before :each do
      @email1 = Email.create!(from_address: address1, to_addresses: [address1])
      @email2 = Email.create!(from_address: address1, to_addresses: [address2])
      @email3 = Email.create!(from_address: address2, to_addresses: [address2])
    end

    describe "#emails_sent" do
      it "should be able to find all the emails sent from this address" do
        address1.emails_sent.should == [@email1, @email2]
      end

      it "should be able to find all the emails sent from this address" do
        address2.emails_sent.should == [@email3]
      end
    end

    describe "#emails_received" do
      it "should be able to find all the emails received by this address" do
        address1.emails_received.should == [@email1]
      end

      it "should be able to find all the emails received by this address" do
        address2.emails_received.should == [@email2, @email3]
      end
    end

    describe "#emails" do
      it "should be able to find all the emails that involved this email address" do
        address1.emails.should =~ [@email1, @email2]
      end

      it "should be able to find all the emails that involved this email address" do
        address2.emails.should =~ [@email2, @email3]
      end
    end
  end
end
