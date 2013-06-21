require 'spec_helper'

describe "getting a bunch of screenshots", js: true do

  def screenshot(path)
    page.driver.browser.manage.window.resize_to(1024,640)
    page.save_screenshot(path)
    i = Magick::ImageList.new(path)
    small = i.resize_to_fit(1024 / 1.5)
    small.write(path)
    #exec("open #{path}")
  end

  before :each do
    ApplicationController.any_instance.stub(force_ssl?: false)
  end

  context "no users" do
    it "sign up page" do
      visit new_admin_registration_path
      screenshot("app/assets/images/screenshot1.png")
    end
  end

  context "users" do
    before :each do
      @admin = Admin.create!(email: 'matthew@openaustralia.org', password: 'caplin')
    end

    it "landing page" do
      visit new_admin_session_path
      fill_in "Email", with: "matthew@openaustralia.org"
      fill_in "Password", with: "caplin"
      click_button "Login"
      screenshot("app/assets/images/screenshot2.png")
    end
  end

end