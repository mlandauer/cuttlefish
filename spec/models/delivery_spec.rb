require 'spec_helper'

describe Delivery do
  let(:delivery) { FactoryGirl.create(:delivery) }

  describe "#status" do
    context "delivery is sent" do
      before :each do
        delivery.update_attributes(sent: true)
      end

      it "should be delivered if the status is sent" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(dsn: "2.0.0", time: Time.now, relay: "", delay: "", delays: "", extended_status: "")
        delivery.status.should == "delivered"
      end

      it "should be soft_bounce if the status was deferred" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(dsn: "4.3.0", time: Time.now, relay: "", delay: "", delays: "", extended_status: "")
        delivery.status.should == "soft_bounce"
      end

      it "should be sent if there is no log line" do
        delivery.status.should == "sent"
      end
    
      it "should be delivered if the most recent status was a succesful delivery" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(dsn: "4.3.0", time: 1.hour.ago, relay: "", delay: "", delays: "", extended_status: "")
        delivery.postfix_log_lines.create(dsn: "2.0.0", time: 5.minutes.ago, relay: "", delay: "", delays: "", extended_status: "")
        delivery.status.should == "delivered"     
      end
    end

    it "should be not_sent if the nothing's been sent yet" do
      delivery.status.should == "not_sent"
    end
  end
end
