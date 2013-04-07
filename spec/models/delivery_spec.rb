require 'spec_helper'

describe Delivery do
  describe "#delivered" do
    let(:email) { Email.create!(:to => "matthew@foo.com") }

    it "should be delivered if the status is sent" do
      email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "2.0.0")
      email.deliveries.first.delivered.should == true
    end

    it "should not be delivered if the status is deferred" do
      email.postfix_log_lines.create(to: "matthew@foo.com", dsn: "4.3.0")
      email.deliveries.first.delivered.should == false
    end
  
    it "should be nil if there is no log line with matching email address" do
      email.postfix_log_lines.create(to: "geoff@foo.com", dsn: "4.3.0")
      email.deliveries.first.delivered.should be_nil
    end
  end
end
