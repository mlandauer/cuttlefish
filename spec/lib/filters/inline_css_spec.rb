require "spec_helper"

describe Filters::InlineCss do
  let(:delivery) { mock_model(Delivery) }
  context "html email with no styling" do
    let(:html) { "<p>This is HTML</p>" }

    it "#process_html" do
      Filters::InlineCss.new.process_html(html, delivery).should == <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html><body><p>This is HTML</p></body></html>
      EOF
    end
  end

  context "html email with style block" do
    let(:html) { "<head><style>p { font-size: 20px; }</style></head><body><p>This is HTML</p></body>" }

    it "#process_html" do
      Filters::InlineCss.new.process_html(html, delivery).should == <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html>
<head></head>
<body><p style="font-size: 20px">This is HTML</p></body>
</html>
      EOF
    end
  end
end
