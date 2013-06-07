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
      # TODO Test that this is sent to the Cuttlefish server and the correct App
      before :each do
        # TODO Figure out why this isn't happening automatically
        ActionMailer::Base.deliveries = []
        post :create, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org", subject: "Test", text: "Hello. How are you?"
        ActionMailer::Base.deliveries.count.should == 1
      end
      let(:email) { ActionMailer::Base.deliveries.first }

      it { email.from.should == ["contact@cuttlefish.io"] }
      it { email.to.should == ["matthew@openaustralia.org"] }
      it { email.subject.should == "Test" }
      it { email.text_part.body.should == "Hello. How are you?" }
      it { email.html_part.body.should == "<p>Hello. How are you?</p>" }
    end
  end
end
