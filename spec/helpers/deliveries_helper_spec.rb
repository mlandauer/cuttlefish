require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the DeliveriesHelper. For example:
#
# describe DeliveriesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe DeliveriesHelper do
  describe "clean_html_email_for_display" do
    it "should only show the body of the email and inline css" do
      html = <<-EOF
<html>
  <head>
    <title>A title</title>
    <style>
      body { font-size: 40px; }
      p { font-size: 20px; }
    </style>
  </head>
  <body>
    <p>Some text</p>
  </body>
</html>
      EOF
      helper.clean_html_email_for_display(html).strip.should == "<div style=\"font-size: 40px\">\n\n    <p style=\"font-size: 20px\">Some text</p>\n  </div>"
    end
  end
end
