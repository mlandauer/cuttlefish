require 'spec_helper'

describe TrackingController do
  describe "#open" do
    before :each do
      FactoryGirl.create(:delivery, id: 101)
    end

    it "should be succesful when the correct hash is used" do
      # Note that this request is being made via http (not https)
      get :open, delivery_id: 101, hash: "59620c1214fb2a2404187bd7447c4972b3f11d78"
      expect(response).to be_success
    end

    it "should 404 when hash isn't recognised" do
      expect { get :open, delivery_id: 101, hash: "123"}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should register the open event" do
      get :open, delivery_id: 101, hash: "59620c1214fb2a2404187bd7447c4972b3f11d78"
      Delivery.find(101).open_events.count.should == 1
    end

    context "read only mode" do
      before(:each) {Rails.configuration.stub(cuttlefish_read_only_mode: true)}

      it "should be succesful when the correct hash is used" do
        # Note that this request is being made via http (not https)
        get :open, delivery_id: 101, hash: "59620c1214fb2a2404187bd7447c4972b3f11d78"
        expect(response).to be_success
      end

      it "should not register the open event" do
        get :open, delivery_id: 101, hash: "59620c1214fb2a2404187bd7447c4972b3f11d78"
        Delivery.find(101).open_events.count.should == 0
      end
    end
  end

  describe "#click" do
    before :each do
      @delivery_link = FactoryGirl.create(:delivery_link, id: 204)
      DeliveryLink.any_instance.stub(url: "http://foo.com")
    end

    context "When the correct hash and id are used" do
      context "the delivery_link exists" do
        it "should redirect" do
          get :click, delivery_link_id: 204, hash: HashId.hash(204)
          expect(response).to redirect_to("http://foo.com")
        end

        it "should log the event" do
          HashId.stub(valid?: true)
          delivery_link = mock_model(DeliveryLink, url: "http://foo.com")
          DeliveryLink.should_receive(:find_by_id).with("204").and_return(delivery_link)
          delivery_link.should_receive(:add_click_event)
          get :click, delivery_link_id: 204, hash: HashId.hash(204)
        end
      end

      context "the delivery_link doesn't exist and url provided" do
        it "should redirect to to the given url" do
          get :click, delivery_link_id: 123, hash: HashId.hash(123), url: "http://bar.com?foo=baz"
          expect(response).to redirect_to("http://bar.com?foo=baz")
        end
      end
    end

    context "read only mode" do
      before(:each) { Rails.configuration.stub(cuttlefish_read_only_mode: true)}

      it "should redirect" do
        get :click, delivery_link_id: 204, hash: HashId.hash(204)
        expect(response).to redirect_to("http://foo.com")
      end

      it "should not log the event" do
        get :click, delivery_link_id: 204, hash: HashId.hash(204)
        DeliveryLink.find(204).click_events.count.should == 0
      end
    end

    it "should 404 when the wrong id is used" do
      expect { get :click, delivery_link_id: 122, hash: "a5ff8760c7cf5763a4008c338d617f71542e362f"}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should 4040 when the wrong hash is used" do
      expect { get :click, delivery_link_id: 204, hash: "123"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
