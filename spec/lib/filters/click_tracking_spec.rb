require "spec_helper"

describe Filters::ClickTracking do
  let(:delivery) do
    delivery = Delivery.new(id: 673)
    delivery.stub(update_status!: nil)
    delivery.save!
    delivery
  end
  let(:filter) { Filters::ClickTracking.new }
  let(:email) { mock_model(Email, custom_tracking_domain: nil, click_tracking_enabled?: true) }

  describe "#data" do
    it "should replace html links with tracking links" do
      mail = Mail.new do
        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1><a href="http://foo.com?a=2">Hello!</a><p>Some text</p><a href="http://www.bar.com">Boing</a>'
        end
      end
      delivery.stub(data: mail.encoded, email: email)
      filter.should_receive(:rewrite_url).with("http://foo.com?a=2", delivery).and_return("http://cuttlefish.io/1/sdfsd")
      filter.should_receive(:rewrite_url).with("http://www.bar.com", delivery).and_return("http://cuttlefish.io/2/sdjfs")
      Mail.new(filter.data(delivery)).html_part.decoded.should == <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body>
<h1>This is HTML</h1>
<a href="http://cuttlefish.io/1/sdfsd">Hello!</a><p>Some text</p>
<a href="http://cuttlefish.io/2/sdjfs">Boing</a>
</body></html>
      EOF
    end
  end

  describe ".rewrite_url" do
    before :each do
      delivery.stub(email: email)
    end
    it "should rewrite the first link" do
      Link.should_receive(:find_or_create_by).with(url: "http://foo.com?a=2").and_return(mock_model(Link, id: 10))
      DeliveryLink.should_receive(:find_or_create_by).with(delivery_id: 673, link_id: 10).and_return(mock(DeliveryLink, id: 321))
      HashId.stub(hash: "sdfsd")
      filter.rewrite_url("http://foo.com?a=2", delivery).should == "https://cuttlefish.example.org/l/321/sdfsd"
    end
  end
end
