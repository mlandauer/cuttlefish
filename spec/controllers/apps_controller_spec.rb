require 'spec_helper'

describe AppsController, type: :controller do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  context "signed in" do
    let(:team) { Team.create! }
    let(:admin) { team.admins.create!(email: "matthew@foo.bar", password: "foobar") }
    before(:each) { sign_in admin }

    describe "POST create" do
      it "should create an app that is part of the current user's team" do
        post :create, params: { app: {
          name: "My New App",
          open_tracking_enabled: "0",
          click_tracking_enabled: "1"
        } }
        app = App.where(cuttlefish: false).first
        expect(app.name).to eq "My New App"
        expect(app.team).to eq team
        expect(response).to redirect_to app
      end

      it "should have errors on the variable when there's a validation error" do
        post :create, params: { app: {
          name: "",
          open_tracking_enabled: false,
          click_tracking_enabled: false
        } }
        expect(assigns(:app).errors.messages).to eq ({
          name: [
            "can't be blank",
            "only letters, numbers, spaces and underscores"
          ]
        })
        expect(assigns(:app).errors.details).to eq ({
          name: [
            { error: :blank },
            { error: :invalid }
          ]
        })
      end
    end

    describe "#update" do
      let(:app) { create(:app, team: team) }

      it "should be able to update just the open_tracking_enabled" do
        put :update, params: { id: app.id, app: { open_tracking_enabled: '0' } }
        expect(response).to redirect_to app_path(app)
        app.reload
        expect(app.open_tracking_enabled).to eq false  
      end

      it "should be able to update just the from domain" do
        put :update, params: { id: app.id, app: { from_domain: 'foo.com' } }
        expect(response).to redirect_to dkim_app_path(app)
        app.reload
        expect(app.from_domain).to eq 'foo.com'
      end
    end
  end
end
