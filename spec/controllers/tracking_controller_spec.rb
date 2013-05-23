require 'spec_helper'

describe TrackingController do
  describe "#open" do
    context "A delivery" do
      before :each do
        email = FactoryGirl.create(:email)
        Delivery.create!(open_tracked_hash: "sdhf", email: email)
      end

      it "should be succesful when the correct hash is used" do
        # Note that this request is being made via http (not https)
        get :open, hash: "sdhf"
        expect(response).to be_success
      end

      it "should respond to https requests as well with no redirects" do
        request.env['HTTPS'] = 'on'
        get :open, hash: "sdhf"
        expect(response).to be_success
      end

      it "should 404 when hash isn't recognised" do
        expect { get :open, :hash => "123"}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#open2" do
    before :each do
      delivery = FactoryGirl.create(:delivery, id: 101)
    end

    it "should be succesful when the correct hash is used" do
      # Note that this request is being made via http (not https)
      get :open2, delivery_id: 101, hash: "df73d6aecbe72eb3abb72b5413674020fae69a2a"
      expect(response).to be_success
    end    

    it "should 404 when hash isn't recognised" do
      expect { get :open2, delivery_id: 101, hash: "123"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
