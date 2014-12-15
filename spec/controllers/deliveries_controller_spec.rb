require 'spec_helper'

describe DeliveriesController, type: :controller do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  context "signed in" do
    let(:team) { Team.create! }
    before :each do
      admin = team.admins.create!(email: "foo@bar.com", password: "guess this")
      sign_in admin
    end

    describe "GET index" do
      it "assigns all deliveries as @deliveries" do
        delivery = FactoryGirl.create(:delivery)
        # Make the email app part of this team
        delivery.email.app.update_attributes(team_id: team.id)
        get :index, {}
        assigns(:deliveries).should eq([delivery])
      end
    end

    describe "GET show" do
      it "assigns the requested delivery as @delivery" do
        delivery = FactoryGirl.create(:delivery)
        # Make the email app part of this team
        delivery.email.app.update_attributes(team_id: team.id)
        get :show, {id: delivery.to_param}
        assigns(:delivery).should eq(delivery)
      end
    end
  end
end
