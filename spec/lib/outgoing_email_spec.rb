require "spec_helper"

describe OutgoingEmail do
  describe "#send" do
    context "an email with two recipients" do
      # TODO This should be optimised in future so that if the content is the same
      # it's sent out in one go
      it "should only send out two emails" do
        email = FactoryGirl.create(:email)
        Delivery.create!(email: email, address: Address.create!(text: "foo@bar.com"))
        Delivery.create!(email: email, address: Address.create!(text: "peter@bar.com"))
        email.reload

        outgoing = OutgoingEmail.new(email)
        smtp = mock
        smtp.should_receive(:send_message).twice.and_return(mock(message: ""))
        Net::SMTP.stub(:start).and_yield(smtp)
        outgoing.send
      end
    end

    context "an email with one recipient" do
      before :each do
        @email = FactoryGirl.create(:email, to: "foo@bar.com", data: "to: foo@bar.com\n\nMy original data")
        @outgoing = OutgoingEmail.new(@email)
      end

      it "should open an smtp connection to localhost port 1025" do
        Net::SMTP.should_receive(:start).with("localhost", 1025)
        @outgoing.send
      end

      it "should send an email to foo@bar.com" do
        smtp = mock
        smtp.should_receive(:send_message).with(anything(), anything(), ["foo@bar.com"]).and_return(mock(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should use data to figure out what to send" do
        smtp = mock
        Filters::Master.any_instance.stub(:data).and_return("My altered data")
        smtp.should_receive(:send_message).with("My altered data", anything(), anything()).and_return(mock(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should set the postfix queue id on the deliveries based on the response from the server" do
        response = mock(message: "250 2.0.0 Ok: queued as A123")
        smtp = mock(send_message: response)
        Net::SMTP.stub(:start).and_yield(smtp)
        OutgoingEmail.should_receive(:extract_postfix_queue_id_from_smtp_message).with("250 2.0.0 Ok: queued as A123").and_return("A123")
        @outgoing.send
        @email.deliveries.each{|d| d.postfix_queue_id.should == "A123"}
      end

      context "deliveries is empty" do
        before :each do
          Delivery.any_instance.stub(:send?).and_return(false)
        end

        it "should send no emails" do
          # TODO Ideally it shouldn't open a connection to the smtp server at all
          smtp = mock
          smtp.should_not_receive(:send_message)
          Net::SMTP.stub(:start).and_yield(smtp)
          @outgoing.send
        end
      end

      context "don't actually send anything" do
        before :each do
          smtp = mock(send_message: mock(message: ""))
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
      OutgoingEmail.extract_postfix_queue_id_from_smtp_message("250 2.0.0 Ok: queued as 2F63736D4A27\n").should == "2F63736D4A27"
    end

    it "should ignore any other form" do
      OutgoingEmail.extract_postfix_queue_id_from_smtp_message("250 250 Message accepted").should be_nil
    end
  end
end
