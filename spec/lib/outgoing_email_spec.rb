require "spec_helper"

describe OutgoingEmail do
  describe "#send" do
    context "an email with one recipient" do
      before :each do
        @email = Email.create!(:to => "foo@bar.com", :data => "My original data")
        @outgoing = OutgoingEmail.new(@email)
      end

      it "should open an smtp connection to localhost port 25" do
        Net::SMTP.should_receive(:start).with("localhost", 25)
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
        @outgoing.should_receive(:data).and_return("My altered data")
        smtp.should_receive(:send_message).with("My altered data", anything(), anything()).and_return(mock(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should use data by default to figure out what to send" do
        smtp = mock
        smtp.should_receive(:send_message).with("My original data", anything(), anything()).and_return(mock(message: ""))
        Net::SMTP.should_receive(:start).and_yield(smtp)
        @outgoing.send
      end

      it "should send an email to the list of addresses specified in deliveries" do
        delivery_to_forward = mock(:update_attribute => nil)
        delivery_to_forward.stub_chain(:address, :text).and_return("foo@foo.com")
        @outgoing.should_receive(:deliveries).at_least(:once).and_return([delivery_to_forward])    
        smtp = mock
        smtp.should_receive(:send_message).with(anything(), anything(), ["foo@foo.com"]).and_return(mock(message: ""))
        Net::SMTP.stub(:start).and_yield(smtp)
        @outgoing.send
      end

      context "deliveries is empty" do
        before :each do
          @outgoing.stub(:deliveries).and_return([])
        end

        it "should send no emails" do
          Net::SMTP.should_not_receive(:start)
          @outgoing.send
        end
      end

      context "don't actually send anything" do
        before :each do
          Net::SMTP.stub(:start)
        end

        it "should record to which destinations the email has been sent" do
          @email.deliveries.first.sent?.should be_false
        end

        it "should record to which destinations the email has been sent" do
          @outgoing.send
          @email.deliveries.first.sent?.should be_true
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