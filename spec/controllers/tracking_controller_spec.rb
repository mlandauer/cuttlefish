require 'spec_helper'

describe TrackingController do
  describe "#open" do
    context "A delivery" do
      before :each do
        email = Email.create!
        Delivery.create!(open_tracked_hash: "sdhf", email: email)
      end

      it "should be succesful when the correct hash is used" do
        get :open, hash: "sdhf"
        expect(response).to be_success
      end

      it "should 404 when hash isn't recognised" do
        expect { get :open, :hash => "123"}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
