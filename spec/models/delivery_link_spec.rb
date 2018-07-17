require 'spec_helper'

describe DeliveryLink do
  describe "#add_click_event" do
    it "should log the link event with some info from the current request" do
      request = double("Request", env: {"HTTP_USER_AGENT" => "some user agent info"},
        referer: "http://foo.com", remote_ip: "1.2.3.4")
      delivery_link = FactoryBot.create(:delivery_link)
      delivery_link.add_click_event(request)
      expect(delivery_link.click_events.count).to eq 1
      e = delivery_link.click_events.first
      expect(e.user_agent).to eq "some user agent info"
      expect(e.referer).to eq "http://foo.com"
      expect(e.ip).to eq "1.2.3.4"
    end
  end
end
