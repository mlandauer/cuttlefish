require 'spec_helper'

describe Delivery do
  let(:address) { Address.create!(text: "matthew@foo.com") }
  let(:email) { Email.create!(to_addresses: [address]) }
  let(:delivery) { Delivery.find_by(email: email, address: address) }

  describe "#status" do
    context "delivery is sent" do
      before :each do
        delivery.stub(:sent?).and_return(true)
      end

      it "should be delivered if the status is sent" do
        delivery.postfix_log_lines.create(dsn: "2.0.0")
        delivery.status.should == "delivered"
      end

      it "should be soft_bounce if the status was deferred" do
        delivery.postfix_log_lines.create(dsn: "4.3.0")
        delivery.status.should == "soft_bounce"
      end

      it "should be unknown if there is no log line" do
        delivery.status.should == "unknown"
      end
    
      it "should be delivered if the most recent status was a succesful delivery" do
        delivery.postfix_log_lines.create(dsn: "4.3.0", time: 1.hour.ago)
        delivery.postfix_log_lines.create(dsn: "2.0.0", time: 5.minutes.ago)
        delivery.status.should == "delivered"     
      end
    end

    it "should be not_sent if the nothing's been sent yet" do
      delivery.status.should == "not_sent"
    end
  end

  describe "#forward?" do
    context "an address where an email was succesfully sent before" do
      before :each do
        Address.any_instance.stub(:status).and_return("delivered")
      end
      it { delivery.forward?.should be_true }
    end

    context "an address where an email hard_bounced most recently" do
      before :each do
        Address.any_instance.stub(:status).and_return("hard_bounce")
      end
      it { delivery.forward?.should be_false }
    end
  end

end
