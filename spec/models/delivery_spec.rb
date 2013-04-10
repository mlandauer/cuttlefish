require 'spec_helper'

describe Delivery do
  describe "#delivered" do
    let(:address) { Address.create!(text: "matthew@foo.com") }
    let(:email) { Email.create!(to_addresses: [address]) }
    let(:delivery) { Delivery.find_by(email: email, address: address) }

    it "should be delivered if the status is sent" do
      delivery.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0")
      delivery.delivered.should == true
    end

    it "should not be delivered if the status is deferred" do
      delivery.postfix_log_lines.create(to: "matthew@foo.com", dsn: "4.3.0", delivery: email.deliveries.first)
      delivery.delivered.should == false
    end
  
    it "should be nil if there is no log line with matching email address" do
      delivery.delivered.should be_nil
    end
  end
end
