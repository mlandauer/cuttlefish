require 'spec_helper'

describe "getting a bunch of screenshots", js: true do
  before :each do
    ApplicationController.any_instance.stub(:force_ssl? => false)
    Admin.create!(:email => 'user@example.com', :password => 'caplin')
  end

  it "sign in page" do
    visit '/admins/sign_in'
    page.save_screenshot("app/assets/images/screenshot1.png")
  end
end