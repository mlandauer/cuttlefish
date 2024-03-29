# frozen_string_literal: true

require "spec_helper"

describe AppsController, type: :controller do
  before do
    request.env["HTTPS"] = "on"
  end

  context "when signed in" do
    let(:team) { Team.create! }
    let(:admin) do
      team.admins.create!(email: "matthew@foo.bar", password: "foobar")
    end

    before do
      sign_in admin
    end

    describe "#show" do
      let(:app) { create(:app, team: team) }

      it "is able to show" do
        get :show, params: { id: app.id }
        expect(response).to be_successful
      end

      context "when app doesn't exist" do
        before { app.destroy }

        it "404S" do
          expect do
            get :show, params: { id: app.id }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when app is in a different team" do
        let(:app) { create(:app) }

        it "redirects to the login page because it's not authenticated properly" do
          get :show, params: { id: app.id }
          expect(response).to redirect_to(new_admin_session_url)
        end
      end
    end

    describe "POST create" do
      it "creates an app that is part of the current user's team" do
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

      it "has errors on the variable when there's a validation error" do
        post :create, params: { app: {
          name: "",
          open_tracking_enabled: false,
          click_tracking_enabled: false
        } }
        expect(assigns(:app).errors.messages).to eq(
          name: [
            "can't be blank",
            "only letters, numbers, spaces and underscores"
          ]
        )
        expect(assigns(:app).errors.details).to eq(
          name: [
            { error: :blank },
            { error: :invalid }
          ]
        )
      end
    end

    describe "#update" do
      let(:app) { create(:app, team: team) }

      it "is able to update just the open_tracking_enabled" do
        put :update, params: { id: app.id, app: { open_tracking_enabled: "0" } }
        expect(response).to redirect_to app_path(app)
        app.reload
        expect(app.open_tracking_enabled).to eq false
      end

      it "is able to update just the from domain" do
        put :update, params: { id: app.id, app: { from_domain: "foo.com" } }
        expect(response).to redirect_to dkim_app_path(app)
        app.reload
        expect(app.from_domain).to eq "foo.com"
      end
    end

    describe "#toggle_dkim" do
      let(:app) { create(:app, team: team, from_domain: "foo.com") }

      it "shows an error" do
        post :toggle_dkim, params: { id: app.id }
        expect(flash[:alert]).to include(
          "From domain doesn't have a DNS record configured correctly"
        )
      end

      context "when DNS for DKIM is correctly configured" do
        before do
          allow_any_instance_of(DkimDns).to receive(:dkim_dns_configured?).and_return(true)
        end

        it "is able to enable DKIM" do
          post :toggle_dkim, params: { id: app.id }
          app.reload
          expect(app.dkim_enabled).to eq true
        end

        it "redirects to the app" do
          post :toggle_dkim, params: { id: app.id }
          expect(response).to redirect_to app_url(app)
        end
      end

      context "when DKIM is enabled" do
        before do
          allow_any_instance_of(DkimDns).to receive(:dkim_dns_configured?).and_return(true)
          app.update!(dkim_enabled: true)
        end

        it "is able to disable DKIM" do
          post :toggle_dkim, params: { id: app.id }
          app.reload
          expect(app.dkim_enabled).to eq false
        end

        it "redirects to the app" do
          post :toggle_dkim, params: { id: app.id }
          expect(response).to redirect_to app_url(app)
        end
      end
    end

    describe "#upgrade_dkim" do
      context "with a legacy dkim selector" do
        let(:app) { create(:app, team: team, legacy_dkim_selector: true) }

        it "upgrades the dkim selector" do
          post :upgrade_dkim, params: { id: app.id }
          app.reload
          expect(app.legacy_dkim_selector).to eq false
        end

        it "redirects back to the app" do
          post :upgrade_dkim, params: { id: app.id }
          expect(response).to redirect_to app_url(app)
        end

        it "lets the user know that it all worked" do
          post :upgrade_dkim, params: { id: app.id }
          expect(flash[:notice]).to eq(
            "App My App successfully upgraded to use the new DNS settings"
          )
        end
      end

      context "when dkim selector already upgraded" do
        let(:app) { create(:app, team: team, legacy_dkim_selector: false) }

        it "does not change the selector" do
          post :upgrade_dkim, params: { id: app.id }
          app.reload
          expect(app.legacy_dkim_selector).to eq false
        end
      end

      context "when app is in a different team" do
        let(:app) { create(:app, legacy_dkim_selector: true) }

        it "redirects to the login page because it's not authenticated properly" do
          post :upgrade_dkim, params: { id: app.id }
          expect(response).to redirect_to(new_admin_session_url)
        end
      end

      context "when app doesn't exist" do
        let(:app) { create(:app, team: team, legacy_dkim_selector: false) }

        before { app.destroy }

        it "raises an error" do
          expect do
            post :upgrade_dkim, params: { id: app.id }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
