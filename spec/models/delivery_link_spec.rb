require 'spec_helper'

describe DeliveryLink do
  describe "#add_link_event" do
    it "should log the link event with some info from the current request" do
      request = mock("Request", env: {"HTTP_USER_AGENT" => "some user agent info"},
        referer: "http://foo.com", remote_ip: "1.2.3.4")
      delivery_link = FactoryGirl.create(:delivery_link)
      delivery_link.add_link_event(request)
      delivery_link.link_events.count.should == 1
      e = delivery_link.link_events.first
      e.user_agent.should == "some user agent info"
      e.referer.should == "http://foo.com"
      e.ip.should == "1.2.3.4"
    end
  end
end
