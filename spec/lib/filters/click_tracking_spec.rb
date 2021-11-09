# frozen_string_literal: true

require "spec_helper"

describe Filters::ClickTracking do
  let(:filter) do
    Filters::ClickTracking.new(
      delivery_id: 673,
      enabled: true,
      tracking_domain_info: {
        protocol: "https",
        domain: "links.bar.com"
      }
    )
  end

  describe "#data" do
    it "replaces html links with tracking links" do
      mail = Mail.new do
        html_part do
          content_type "text/html; charset=UTF-8"
          body "<h1>This is HTML</h1>" \
               "<a href=\"http://foo.com?a=2\">Hello with “some” UTF-8 ☃!</a>" \
               "<p>Some text</p>" \
               "<a href=\"http://www.bar.com\">Boing</a>"
        end
      end
      expect(filter).to receive(:rewrite_url)
        .with("http://foo.com?a=2").and_return("http://cuttlefish.io/1/sdfsd")
      expect(filter).to receive(:rewrite_url)
        .with("http://www.bar.com").and_return("http://cuttlefish.io/2/sdjfs")
      expect(
        filter.filter_mail(mail).html_part.decoded.gsub("\r\n", "\n")
      ).to eq <<~HTML
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
        <html><body>
        <h1>This is HTML</h1>
        <a href="http://cuttlefish.io/1/sdfsd">Hello with “some” UTF-8 ☃!</a><p>Some text</p>
        <a href="http://cuttlefish.io/2/sdjfs">Boing</a>
        </body></html>
      HTML
    end
  end

  describe ".rewrite_url" do
    it "rewrites the first link" do
      expect(Link).to receive(:find_or_create_by)
        .with(url: "http://foo.com?a=2").and_return(mock_model(Link, id: 10))
      expect(DeliveryLink).to receive(:find_or_create_by)
        .with(delivery_id: 673, link_id: 10)
        .and_return(double(DeliveryLink, id: 321))
      allow(HashId).to receive(:hash)
        .with("321-http://foo.com?a=2").and_return("sdfsd")
      expect(filter.rewrite_url("http://foo.com?a=2")).to eq "https://links.bar.com/l2/321/sdfsd?url=http%3A%2F%2Ffoo.com%3Fa%3D2"
    end
  end
end
