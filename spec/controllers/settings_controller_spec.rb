require 'spec_helper'

describe SettingsController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  context "signed in" do
    before :each do
      admin = Admin.create!(email: "foo@bar.com", password: "guess this")
      sign_in admin
    end

    it "#edit" do
      setting = mock("Setting")
      Settings.should_receive(:smtp_all_authenticated).and_return(setting)
      get :edit
      assigns(:smtp_all_authenticated).should == setting
    end

    it "#update" do
      Settings.should_receive(:smtp_all_authenticated=).with(true)
      post :update, smtp_all_authenticated: true
      response.should redirect_to edit_settings_url
    end
  end
end
