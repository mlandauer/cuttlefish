require "spec_helper"

describe DeliveriesController do
  describe "routing" do

    it "routes to #index" do
      get("/deliveries").should route_to("deliveries#index")
    end

    it "routes to #show" do
      get("/deliveries/1").should route_to("deliveries#show", id: "1")
    end

  end
end
