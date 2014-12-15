require 'spec_helper'

describe Address do
  context "three emails" do
    let (:address1) { Address.create!(text: "matthew@foo.com") }
    let (:address2) { Address.create!(text: "peter@bar.com") }
    before :each do
      @email1 = FactoryGirl.create(:email, from_address: address1, to_addresses: [address1])
      @email2 = FactoryGirl.create(:email, from_address: address1, to_addresses: [address2])
      @email3 = FactoryGirl.create(:email, from_address: address2, to_addresses: [address2])
    end

    describe "#emails_sent" do
      it "should be able to find all the emails sent from this address" do
        address1.emails_sent.order(:id).should == [@email1, @email2]
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

    describe "#status" do
      it "should take the most recent delivery attempt to this address as the status" do
        delivery2 = Delivery.find_by(email: @email2, address: address2)
        delivery3 = Delivery.find_by(email: @email3, address: address2)
        # TODO: Replace with factory_girl
        delivery2.postfix_log_lines.create!(dsn: "4.5.0", time: 10.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        delivery3.postfix_log_lines.create!(dsn: "2.0.0", time: 5.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        address2.status.should == "delivered"
      end

      it "should take the most recent delivery attempt to this address as the status" do
        delivery2 = Delivery.find_by(email: @email2, address: address2)
        delivery3 = Delivery.find_by(email: @email3, address: address2)
        # TODO: Replace with factory_girl
        delivery2.postfix_log_lines.create!(dsn: "4.5.0", time: 5.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        delivery3.postfix_log_lines.create!(dsn: "2.0.0", time: 10.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        address2.status.should == "soft_bounce"
      end

      it "should be sent if there are no delivery attempts" do
        address2.status.should == "sent"
      end
    end

    describe "#blacklisted?" do
      let(:team) { Team.create! }

      context "address1 is not blacklisted" do
        it {address1.blacklisted?(team).should_not be_truthy}
      end

      context "address1 is blacklisted" do
        before(:each) { team.black_lists.create(address: address1)}
        it {address1.blacklisted?(team).should be_truthy}
      end
    end
  end
end
