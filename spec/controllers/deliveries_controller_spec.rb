# frozen_string_literal: true

require "spec_helper"

describe DeliveriesController, type: :controller do
  before :each do
    request.env["HTTPS"] = "on"
  end

  context "signed in" do
    let(:team) { Team.create! }
    before :each do
      admin = team.admins.create!(email: "foo@bar.com", password: "guess this")
      # Make a JSON web token without an expiry
      session[:jwt_token] = JWT.encode({ admin_id: admin.id }, ENV["JWT_SECRET"], "HS512")
      sign_in admin
    end

    describe "GET index" do
      it "assigns all deliveries as @deliveries" do
        delivery = create(:delivery)
        # Make the email app part of this team
        delivery.email.app.update_attributes(team_id: team.id)
        get :index, params: {}
        expect(assigns(:deliveries).count).to eq 1
        expect(assigns(:deliveries).first.to).to eq delivery.to
        expect(assigns(:deliveries).first.created_at).to eq(
          delivery.created_at.utc.iso8601
        )
        expect(assigns(:deliveries).first.status).to eq delivery.status
      end
    end

    describe "GET show" do
      it "assigns the requested delivery as @delivery" do
        delivery = create(:delivery)
        # Make the email app part of this team
        delivery.email.app.update_attributes(team_id: team.id)
        get :show, params: { id: delivery.to_param }
        expect(assigns(:delivery).to).to eq delivery.to
        expect(assigns(:delivery).created_at).to eq(
          delivery.created_at.utc.iso8601
        )
        expect(assigns(:delivery).status).to eq delivery.status
      end
    end
  end
end
