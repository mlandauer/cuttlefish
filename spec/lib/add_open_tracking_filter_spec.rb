require "spec_helper"

describe AddOpenTrackingFilter do
  describe "#data" do
    context "An html email with no text part" do
      let(:mail) do
        Mail.new do
          html_part do
            content_type 'text/html; charset=UTF-8'
            body '<h1>This is HTML</h1>'
          end
        end
      end
      let(:filter) { AddOpenTrackingFilter.new(mock(:data => mail.encoded)) }

      it "should insert an image at the bottom of the html" do
        Mail.new(filter.data).parts.first.body.should ==
          '<h1>This is HTML</h1><img src="http://cuttlefish.example.org/o123.gif" />'
      end
    end
  end
end