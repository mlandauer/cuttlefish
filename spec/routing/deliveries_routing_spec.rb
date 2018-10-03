# frozen_string_literal: true

require "spec_helper"

describe DeliveriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/emails")).to route_to("deliveries#index")
    end

    it "routes to #show" do
      expect(get("/emails/1")).to route_to("deliveries#show", id: "1")
    end

  end
end
