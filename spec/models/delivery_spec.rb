require 'spec_helper'

describe Delivery do
  let(:delivery) { FactoryGirl.create(:delivery) }

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
end
