require 'spec_helper'

describe DeliveriesController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  context "signed in" do
    before :each do
      team = Team.create!
      admin = team.admins.create!(email: "foo@bar.com", password: "guess this")
      sign_in admin
    end

    describe "GET index" do
      it "assigns all deliveries as @deliveries" do
        delivery = FactoryGirl.create(:delivery)
        get :index, {}
        assigns(:deliveries).should eq([delivery])
      end
    end

    describe "GET show" do
      it "assigns the requested delivery as @delivery" do
        delivery = FactoryGirl.create(:delivery)
        get :show, {id: delivery.to_param}
        assigns(:delivery).should eq(delivery)
      end
    end
  end
end
