# coding: utf-8
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
describe DeliveriesHelper, type: :helper do
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

    it "should preserve UTF-8 characters" do
      helper.clean_html_email_for_display("This is some “test UTF-8” stuff").should == "<div><p>This is some “test UTF-8” stuff</p></div>"
    end
  end
end
