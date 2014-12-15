require "spec_helper"

describe DeliveriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      get("/emails").should route_to("deliveries#index")
    end

    it "routes to #show" do
      get("/emails/1").should route_to("deliveries#show", id: "1")
    end

  end
end
