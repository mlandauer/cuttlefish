require 'spec_helper'

describe ApplicationHelper do
  describe "#bootstrap_flash" do
    it "should be empty when there is no flash" do
      helper.bootstrap_flash.should == ""
    end

    it "should show an error message" do
      helper.stub(:flash).and_return(:error => "This is a bad thing")
      helper.bootstrap_flash.should == '<div class="alert fade in alert-error"><button class="close" data-dismiss="alert">&times;</button>This is a bad thing</div>'
    end

    it "should show a notice message" do
      helper.stub(:flash).and_return(:notice => "This is interesting")
      helper.bootstrap_flash.should == '<div class="alert fade in alert-success"><button class="close" data-dismiss="alert">&times;</button>This is interesting</div>'
    end

    it "should show two messages together" do
      helper.stub(:flash).and_return(:error => "This is a bad thing", :notice => "This is interesting")
      helper.bootstrap_flash.should == "<div class=\"alert fade in alert-error\"><button class=\"close\" data-dismiss=\"alert\">&times;</button>This is a bad thing</div>\n<div class=\"alert fade in alert-success\"><button class=\"close\" data-dismiss=\"alert\">&times;</button>This is interesting</div>"
    end
  end
end
