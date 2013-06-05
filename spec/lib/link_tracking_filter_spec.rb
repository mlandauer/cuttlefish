require "spec_helper"

describe LinkTrackingFilter do
  let(:delivery) do
    delivery = Delivery.new(id: 673)
    delivery.stub(update_status!: nil)
    delivery.save!
    delivery
  end
  let(:filter) { LinkTrackingFilter.new(delivery) }

  describe "#data" do
    it "should replace html links with tracking links" do
      mail = Mail.new do
        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1><a href="http://foo.com?a=2">Hello!</a><p>Some text</p><a href="http://www.bar.com">Boing</a>'
        end
      end
      delivery.stub(data: mail.encoded)
      LinkTrackingFilter.should_receive(:rewrite_url).with("http://foo.com?a=2").and_return("http://cuttlefish.io/1/sdfsd")
      LinkTrackingFilter.should_receive(:rewrite_url).with("http://www.bar.com").and_return("http://cuttlefish.io/2/sdjfs")
      Mail.new(filter.data).html_part.decoded.should == <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body>
<h1>This is HTML</h1>
<a href="http://cuttlefish.io/1/sdfsd">Hello!</a><p>Some text</p>
<a href="http://cuttlefish.io/2/sdjfs">Boing</a>
</body></html>
      EOF
    end
  end
end