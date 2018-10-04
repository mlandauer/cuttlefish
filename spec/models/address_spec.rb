# frozen_string_literal: true

require "spec_helper"

describe Address do
  context "three emails" do
    let(:address1) { Address.create!(text: "matthew@foo.com") }
    let(:address2) { Address.create!(text: "peter@bar.com") }
    before :each do
      @email1 = FactoryBot.create(:email, from_address: address1, to_addresses: [address1])
      @email2 = FactoryBot.create(:email, from_address: address1, to_addresses: [address2])
      @email3 = FactoryBot.create(:email, from_address: address2, to_addresses: [address2])
    end

    describe "#emails_sent" do
      it "should be able to find all the emails sent from this address" do
        expect(address1.emails_sent.order(:id)).to eq [@email1, @email2]
      end

      it "should be able to find all the emails sent from this address" do
        expect(address2.emails_sent).to eq [@email3]
      end
    end

    describe "#emails_received" do
      it "should be able to find all the emails received by this address" do
        expect(address1.emails_received).to eq [@email1]
      end

      it "should be able to find all the emails received by this address" do
        expect(address2.emails_received).to eq [@email2, @email3]
      end
    end

    describe "#emails" do
      it "should be able to find all the emails that involved this email address" do
        expect(address1.emails).to match_array [@email1, @email2]
      end

      it "should be able to find all the emails that involved this email address" do
        expect(address2.emails).to match_array [@email2, @email3]
      end
    end

    describe "#status" do
      it "should take the most recent delivery attempt to this address as the status" do
        delivery2 = Delivery.find_by(email: @email2, address: address2)
        delivery3 = Delivery.find_by(email: @email3, address: address2)
        # TODO: Replace with factory_girl
        delivery2.postfix_log_lines.create!(dsn: "4.5.0", time: 10.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        delivery3.postfix_log_lines.create!(dsn: "2.0.0", time: 5.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        expect(address2.status).to eq "delivered"
      end

      it "should take the most recent delivery attempt to this address as the status" do
        delivery2 = Delivery.find_by(email: @email2, address: address2)
        delivery3 = Delivery.find_by(email: @email3, address: address2)
        # TODO: Replace with factory_girl
        delivery2.postfix_log_lines.create!(dsn: "4.5.0", time: 5.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        delivery3.postfix_log_lines.create!(dsn: "2.0.0", time: 10.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        expect(address2.status).to eq "soft_bounce"
      end

      it "should be sent if there are no delivery attempts" do
        expect(address2.status).to eq "sent"
      end
    end
  end
end
