require "spec_helper"

describe OutgoingDelivery do
  describe "#send" do
    context "an email with one recipient" do
      before :each do
        @email = FactoryGirl.create(:email, to: "foo@bar.com", data: "to: foo@bar.com\n\nMy original data")
        @outgoing = OutgoingDelivery.new(@email.deliveries.first)
      end

      it "should open an smtp connection to localhost port 1025" do
        Net::SMTP.should_receive(:start).with("localhost", 1025)
        @outgoing.send
      end

      it "should send an email with a return-path" do
        smtp = double
        Delivery.any_instance.should_receive(:return_path).and_return("bounce-address@cuttlefish.io")
        smtp.should_receive(:send_message).with(anything(), "bounce-address@cuttlefish.io", anything()).and_return(double(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should send an email to foo@bar.com" do
        smtp = double
        smtp.should_receive(:send_message).with(anything(), anything(), ["foo@bar.com"]).and_return(double(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should use data to figure out what to send" do
        smtp = double
        filtered_mail = Mail.new do
          body "My altered data"
        end
        Filters::Master.any_instance.stub(:filter_mail).and_return(filtered_mail)
        smtp.should_receive(:send_message).with(filtered_mail.to_s, anything(), anything()).and_return(double(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should set the postfix queue id on the deliveries based on the response from the server" do
        response = double(message: "250 2.0.0 Ok: queued as A123")
        smtp = double(send_message: response)
        Net::SMTP.stub(:start).and_yield(smtp)
        OutgoingDelivery.should_receive(:extract_postfix_queue_id_from_smtp_message).with("250 2.0.0 Ok: queued as A123").and_return("A123")
        @outgoing.send
        @email.deliveries.each{|d| d.postfix_queue_id.should == "A123"}
      end

      context "deliveries is empty" do
        before :each do
          Delivery.any_instance.stub(:send?).and_return(false)
        end

        it "should send no emails" do
          # TODO Ideally it shouldn't open a connection to the smtp server at all
          smtp = double
          smtp.should_not_receive(:send_message)
          Net::SMTP.stub(:start).and_yield(smtp)
          @outgoing.send
        end
      end

      context "don't actually send anything" do
        before :each do
          smtp = double(send_message: double(message: ""))
          Net::SMTP.stub(:start).and_yield(smtp)
        end

        it "should record to which destinations the email has been sent" do
          @email.deliveries.first.sent?.should be_falsy
        end

        it "should record to which destinations the email has been sent" do
          @outgoing.send
          @email.deliveries.first.sent?.should be_truthy
        end
      end
    end
  end

  describe ".extract_postfix_queue_id_from_smtp_message" do
    it "should extract the queue id" do
      OutgoingDelivery.extract_postfix_queue_id_from_smtp_message("250 2.0.0 Ok: queued as 2F63736D4A27\n").should == "2F63736D4A27"
    end

    it "should ignore any other form" do
      OutgoingDelivery.extract_postfix_queue_id_from_smtp_message("250 250 Message accepted").should be_nil
    end
  end
end
