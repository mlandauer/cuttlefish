# frozen_string_literal: true

require "spec_helper"

describe Filters::InlineCss do
  describe "#filter_html" do
    context "with html email with no styling" do
      let(:html) { "<p>This is HTML with “some” UTF-8</p>" }

      it do
        expect(described_class.new(enabled: true).filter_html(html)).to eq <<~HTML
          <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
          <html><body><p>This is HTML with “some” UTF-8</p></body></html>
        HTML
      end
    end

    context "with html email with style block" do
      let(:html) do
        "<head><style>p { font-size: 20px; }</style></head>" \
          "<body><p>This is HTML with “some” UTF-8</p></body>"
      end

      it do
        expect(described_class.new(enabled: true).filter_html(html)).to eq <<~HTML
          <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
          <html>
          <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>
          <body><p style="font-size: 20px;">This is HTML with “some” UTF-8</p></body>
          </html>
        HTML
      end
    end
  end

  it "doesn't mangle valid html 5" do
    html = '<!DOCTYPE html><a href="#"><table></table></a>'
    expected = '<!DOCTYPE html><html><head></head><body><a href="#"><table></table></a></body></html>'
    expect(described_class.new(enabled: true).filter_html(html).gsub("\n","")).to eq(expected)
  end
end
