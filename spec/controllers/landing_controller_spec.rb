# frozen_string_literal: true

require "spec_helper"

describe LandingController, type: :controller do
  before do
    request.env["HTTPS"] = "on"
  end

  describe "GET index" do
    it do
      get :index
      expect(response.status).to eq(200)
    end

    context "when signed in" do
      before do
        team = Team.create!
        admin = team.admins.create!(
          email: "foo@bar.com",
          password: "guess this"
        )
        sign_in admin
      end

      it do
        get :index
        expect(response).to redirect_to "/dash"
      end
    end
  end
end
