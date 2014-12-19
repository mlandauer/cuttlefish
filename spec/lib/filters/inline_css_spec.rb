# coding: utf-8
require "spec_helper"

describe Filters::InlineCss do
  let(:delivery) { mock_model(Delivery) }
  context "html email with no styling" do
    let(:html) { "<p>This is HTML with “some” UTF-8</p>" }

    it "#process_html" do
      Filters::InlineCss.new(delivery).process_html(html).should == <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body><p>This is HTML with “some” UTF-8</p></body></html>
      EOF
    end
  end

  context "html email with style block" do
    let(:html) { "<head><style>p { font-size: 20px; }</style></head><body><p>This is HTML with “some” UTF-8</p></body>" }

    it "#process_html" do
      Filters::InlineCss.new(delivery).process_html(html).should == <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html>
<head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>
<body><p style="font-size: 20px">This is HTML with “some” UTF-8</p></body>
</html>
      EOF
    end
  end
end
