# frozen_string_literal: true

require "spec_helper"

describe ApplicationHelper, type: :helper do
  describe "#bootstrap_flash" do
    it "should be empty when there is no flash" do
      expect(helper.bootstrap_flash).to eq ""
    end

    it "should show an error message" do
      allow(helper).to receive(:flash).and_return(
        "error" => "This is a bad thing"
      )
      expect(helper.bootstrap_flash).to eq(
        '<div class="alert fade in alert-error">' \
        '<button class="close" data-dismiss="alert">&times;</button>' \
        "This is a bad thing" \
        "</div>"
      )
    end

    it "should show a notice message" do
      allow(helper).to receive(:flash).and_return(
        "notice" => "This is interesting"
      )
      expect(helper.bootstrap_flash).to eq(
        '<div class="alert fade in alert-success">' \
        '<button class="close" data-dismiss="alert">&times;</button>' \
        "This is interesting" \
        "</div>"
      )
    end

    it "should show two messages together" do
      allow(helper).to receive(:flash).and_return(
        "error" => "This is a bad thing", "notice" => "This is interesting"
      )
      expect(helper.bootstrap_flash).to eq(
        "<div class=\"alert fade in alert-error\">" \
        "<button class=\"close\" data-dismiss=\"alert\">&times;</button>" \
        "This is a bad thing" \
        "</div>\n" \
        "<div class=\"alert fade in alert-success\">" \
        "<button class=\"close\" data-dismiss=\"alert\">&times;</button>" \
        "This is interesting" \
        "</div>"
      )
    end
  end

  describe "#nav_menu_item_show_active" do
    it "should create the simple markup required" do
      h = helper.nav_menu_item_show_active("Test email", "/foo/bar")
      expect(h).to eq('<li><a href="/foo/bar">Test email</a></li>')
    end

    it "should handle a block argument" do
      h = helper.nav_menu_item_show_active("/foo/bar") { "Test email" }
      expect(h).to eq('<li><a href="/foo/bar">Test email</a></li>')
    end

    context "/foo/bar is current page" do
      before :each do
        allow(helper).to receive(:current_page?).and_return(true)
      end

      it "should be active" do
        h = helper.nav_menu_item_show_active("Test email", "/foo/bar")
        expect(h).to eq(
          '<li class="active"><a href="/foo/bar">Test email</a></li>'
        )
      end
    end
  end
end
