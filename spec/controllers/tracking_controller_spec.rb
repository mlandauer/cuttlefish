require 'spec_helper'

describe TrackingController do
  describe "#open" do
    before :each do
      FactoryGirl.create(:delivery, id: 101)
    end

    it "should be succesful when the correct hash is used" do
      # Note that this request is being made via http (not https)
      get :open, delivery_id: 101, hash: "df73d6aecbe72eb3abb72b5413674020fae69a2a"
      expect(response).to be_success
    end    

    it "should 404 when hash isn't recognised" do
      expect { get :open, delivery_id: 101, hash: "123"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#link" do
    before :each do
      FactoryGirl.create(:delivery_link, id: 204)
      DeliveryLink.any_instance.stub(url: "http://foo.com")
    end

    it "should redirect when the correct hash and id are used" do
      get :link, delivery_link_id: 204, hash: "542bae7ec2904c85b945b56072c726d8507fc58a"
      expect(response).to redirect_to("http://foo.com")
    end

    it "should 404 when the wrong id is used" do
      expect { get :link, delivery_link_id: 122, hash: "a5ff8760c7cf5763a4008c338d617f71542e362f"}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should 4040 when the wrong hash is used" do
      expect { get :link, delivery_link_id: 204, hash: "123"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
