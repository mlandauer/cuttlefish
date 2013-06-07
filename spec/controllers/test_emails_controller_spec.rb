require 'spec_helper'

describe TestEmailsController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  context "signed in" do
    before :each do
      admin = Admin.create!(email: "foo@bar.com", password: "guess this")
      sign_in admin
    end

    describe "#new" do
      it "should give some default text" do
        get :new
        assigns(:text).should == "Hello folks. Hopefully this should have worked and you should\nbe reading this. So, all is good.\n\nLove,\nThe Awesome Cuttlefish\n<a href=\"http://cuttlefish.io\">http://cuttlefish.io</a>\n"
      end
    end

    describe "#create" do
      it "should send a test email" do
        email = mock("Email")
        TestMailer.should_receive(:test_email).with(App.cuttlefish, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org", cc: nil, subject: "Test", text: "Hello. How are you?").and_return(email)
        email.should_receive(:deliver)
        post :create, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org", subject: "Test", text: "Hello. How are you?"
      end
    end
  end
end
