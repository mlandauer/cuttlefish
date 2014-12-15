require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe "#bootstrap_flash" do
    it "should be empty when there is no flash" do
      helper.bootstrap_flash.should == ""
    end

    it "should show an error message" do
      helper.stub(:flash).and_return(error: "This is a bad thing")
      helper.bootstrap_flash.should == '<div class="alert fade in alert-error"><button class="close" data-dismiss="alert">&times;</button>This is a bad thing</div>'
    end

    it "should show a notice message" do
      helper.stub(:flash).and_return(notice: "This is interesting")
      helper.bootstrap_flash.should == '<div class="alert fade in alert-success"><button class="close" data-dismiss="alert">&times;</button>This is interesting</div>'
    end

    it "should show two messages together" do
      helper.stub(:flash).and_return(error: "This is a bad thing", notice: "This is interesting")
      helper.bootstrap_flash.should == "<div class=\"alert fade in alert-error\"><button class=\"close\" data-dismiss=\"alert\">&times;</button>This is a bad thing</div>\n<div class=\"alert fade in alert-success\"><button class=\"close\" data-dismiss=\"alert\">&times;</button>This is interesting</div>"
    end
  end

  describe "#nav_menu_item_show_active" do
    it "should create the simple markup required" do
      helper.nav_menu_item_show_active("Test email", "/foo/bar").should == '<li><a href="/foo/bar">Test email</a></li>'
    end

    it "should handle a block argument" do
      helper.nav_menu_item_show_active("/foo/bar") { "Test email" }.should == '<li><a href="/foo/bar">Test email</a></li>'
    end

    context "/foo/bar is current page" do
      before :each do
        helper.stub(:current_page?).and_return(true)
      end

      it "should be active" do
        helper.nav_menu_item_show_active("Test email", "/foo/bar").should == '<li class="active"><a href="/foo/bar">Test email</a></li>'
      end
    end
  end
end
