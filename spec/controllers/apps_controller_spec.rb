require 'spec_helper'

describe AppsController, type: :controller do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  describe "POST create" do
    context "signed in" do
      let(:team) { Team.create! }
      let(:admin) { team.admins.create!(email: "matthew@foo.bar", password: "foobar") }
      before(:each) { sign_in admin }

      it "should create an app that is part of the current user's team" do
        post :create, app: {name: "My New App"}
        app = App.first
        expect(app.name).to eq "My New App"
        expect(app.team).to eq team
        expect(response).to redirect_to app
      end
    end
  end

end
