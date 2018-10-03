# frozen_string_literal: true

require "spec_helper"

describe OutgoingDelivery do
  describe "#send" do
    context "an email with one recipient" do
      before :each do
        @email = FactoryBot.create(:email, to: "foo@bar.com", data: "from: contact@foo.com\nto: foo@bar.com\n\nMy original data")
        @outgoing = OutgoingDelivery.new(@email.deliveries.first)
      end

      it "should open an smtp connection to postfix port 25" do
        expect(Net::SMTP).to receive(:start).with("postfix", 25)
        @outgoing.send
      end

      it "should send an email with a return-path" do
        smtp = double
        expect_any_instance_of(Delivery).to receive(:return_path).and_return("bounce-address@cuttlefish.io")
        expect(smtp).to receive(:send_message).with(anything(), "bounce-address@cuttlefish.io", anything()).and_return(double(message: ""))
        expect(Net::SMTP).to receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should send an email to foo@bar.com" do
        smtp = double
        expect(smtp).to receive(:send_message).with(anything(), anything(), ["foo@bar.com"]).and_return(double(message: ""))
        expect(Net::SMTP).to receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should use data to figure out what to send" do
        smtp = double
        filtered_mail = Mail.new do
          body "My altered data"
        end
        allow_any_instance_of(Filters::Master).to receive(:filter_mail).and_return(filtered_mail)
        expect(smtp).to receive(:send_message).with(filtered_mail.to_s, anything(), anything()).and_return(double(message: ""))
        expect(Net::SMTP).to receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should set the postfix queue id on the deliveries based on the response from the server" do
        response = double(message: "250 2.0.0 Ok: queued as A123")
        smtp = double(send_message: response)
        allow(Net::SMTP).to receive(:start).and_yield(smtp)
        expect(OutgoingDelivery).to receive(:extract_postfix_queue_id_from_smtp_message).with("250 2.0.0 Ok: queued as A123").and_return("A123")
        @outgoing.send
        @email.deliveries.each{|d| expect(d.postfix_queue_id).to eq "A123"}
      end

      context "deliveries is empty" do
        before :each do
          allow_any_instance_of(Delivery).to receive(:send?).and_return(false)
        end

        it "should send no emails" do
          # TODO Ideally it shouldn't open a connection to the smtp server at all
          smtp = double
          expect(smtp).to_not receive(:send_message)
          allow(Net::SMTP).to receive(:start).and_yield(smtp)
          @outgoing.send
        end
      end

      context "don't actually send anything" do
        before :each do
          smtp = double(send_message: double(message: ""))
          allow(Net::SMTP).to receive(:start).and_yield(smtp)
        end

        it "should record to which destinations the email has been sent" do
          expect(@email.deliveries.first).to_not be_sent
        end

        it "should record to which destinations the email has been sent" do
          @outgoing.send
          expect(@email.deliveries.first).to be_sent
        end
      end
    end
  end

  describe ".extract_postfix_queue_id_from_smtp_message" do
    it "should extract the queue id" do
      expect(OutgoingDelivery.extract_postfix_queue_id_from_smtp_message("250 2.0.0 Ok: queued as 2F63736D4A27\n")).to eq "2F63736D4A27"
    end

    it "should ignore any other form" do
      expect(OutgoingDelivery.extract_postfix_queue_id_from_smtp_message("250 250 Message accepted")).to be_nil
    end
  end
end
