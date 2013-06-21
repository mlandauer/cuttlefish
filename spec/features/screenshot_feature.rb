require 'spec_helper'

describe "getting a bunch of screenshots", js: true do
  before :each do
    ApplicationController.any_instance.stub(:force_ssl? => false)
    #Admin.create!(:email => 'user@example.com', :password => 'caplin')
  end

  it "sign in page" do
    visit '/admins/sign_in'
    page.driver.browser.manage.window.resize_to(1024,640)
    page.save_screenshot("app/assets/images/screenshot1.png")
    i = Magick::ImageList.new("app/assets/images/screenshot1.png")
    small = i.scale(1.0 / 1.5)
    small.write("app/assets/images/screenshot1.png")

    exec("open app/assets/images/screenshot1.png")
  end
end