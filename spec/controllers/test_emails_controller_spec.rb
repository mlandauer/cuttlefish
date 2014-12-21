require 'spec_helper'

describe TestEmailsController, type: :controller do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  context "signed in" do
    let(:team) { Team.create! }
    before :each do
      admin = team.admins.create!(email: "foo@bar.com", password: "guess this")
      sign_in admin
    end

    describe "#new" do
      it "should give some default text" do
        get :new
        expect(assigns(:text)).to eq "Hello folks. Hopefully this should have worked and you should\nbe reading this. So, all is good.\n\nLove,\nThe Awesome Cuttlefish\n<a href=\"http://cuttlefish.io\">http://cuttlefish.io</a>\n"
      end
    end

    describe "#create" do
      let(:app) { team.apps.create!(name: "Test") }

      it "should send a test email" do
        email = double("Email")
        expect(TestMailer).to receive(:test_email).with(app, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org", cc: nil, subject: "Test", text: "Hello. How are you?").and_return(email)
        expect(email).to receive(:deliver)
        post :create, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org", subject: "Test", text: "Hello. How are you?", app_id: app.id
      end

      it "should redirect to the list of recent emails" do
        allow(TestMailer).to receive_message_chain(:test_email, :deliver)
        post :create, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org", subject: "Test", text: "Hello. How are you?", app_id: app.id
        expect(response).to redirect_to deliveries_url
      end
    end
  end
end
