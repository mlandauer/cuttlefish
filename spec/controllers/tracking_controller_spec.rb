# frozen_string_literal: true

require "spec_helper"

describe TrackingController, type: :controller do
  describe "#open" do
    before :each do
      create(:delivery, id: 101)
    end

    it "is succesful when the correct hash is used" do
      # Note that this request is being made via http (not https)
      get :open, params: {
        delivery_id: 101,
        hash: "e4a8656f793ded530fb9d619af3c6c08a49ead7f"
      }
      expect(response).to be_successful
    end

    it "404S when hash isn't recognised" do
      expect do
        get :open, params: { delivery_id: 101, hash: "123" }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "registers the open event" do
      get :open, params: {
        delivery_id: 101,
        hash: "e4a8656f793ded530fb9d619af3c6c08a49ead7f"
      }
      expect(Delivery.find(101).open_events.count).to eq 1
    end

    context "read only mode" do
      before(:each) do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode)
          .and_return(true)
      end

      it "is succesful when the correct hash is used" do
        # Note that this request is being made via http (not https)
        get :open, params: {
          delivery_id: 101,
          hash: "e4a8656f793ded530fb9d619af3c6c08a49ead7f"
        }
        expect(response).to be_successful
      end

      it "does not register the open event" do
        get :open, params: {
          delivery_id: 101,
          hash: "e4a8656f793ded530fb9d619af3c6c08a49ead7f"
        }
        expect(Delivery.find(101).open_events.count).to eq 0
      end
    end
  end

  describe "#click" do
    before :each do
      @delivery_link = create(:delivery_link, id: 204)
      allow_any_instance_of(DeliveryLink).to receive(:url)
        .and_return("http://foo.com")
    end

    context "When the correct hash and id are used" do
      context "the delivery_link exists" do
        it "redirects" do
          get :click, params: {
            delivery_link_id: 204,
            url: "http://foo.com",
            hash: HashId.hash("204-http://foo.com")
          }
          expect(response).to redirect_to("http://foo.com")
        end

        it "logs the event" do
          allow(HashId).to receive(:valid?).and_return(true)
          delivery_link = mock_model(DeliveryLink, url: "http://foo.com")
          expect(DeliveryLink).to receive(:find_by_id)
            .with("204").and_return(delivery_link)
          expect(delivery_link).to receive(:add_click_event)
          get :click, params: {
            delivery_link_id: 204,
            url: "http://foo.com",
            hash: HashId.hash("204")
          }
        end
      end

      context "the delivery_link doesn't exist and url provided" do
        it "redirects to to the given url" do
          get :click, params: {
            delivery_link_id: 123,
            hash: HashId.hash("123-http://bar.com?foo=baz"),
            url: "http://bar.com?foo=baz"
          }
          expect(response).to redirect_to("http://bar.com?foo=baz")
        end
      end

      context "the url has been changed" do
        it "does not redirect to the given url" do
          expect do
            get :click, params: {
              delivery_link_id: 123,
              hash: HashId.hash("123-http://bar.com?foo=baz"),
              url: "http://bar.com2?foo=baz"
            }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "read only mode" do
      before(:each) do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode)
          .and_return(true)
      end

      it "redirects" do
        get :click, params: {
          delivery_link_id: 204,
          hash: HashId.hash("204-http://foo.com"),
          url: "http://foo.com"
        }
        expect(response).to redirect_to("http://foo.com")
      end

      it "does not log the event" do
        get :click, params: {
          delivery_link_id: 204,
          hash: HashId.hash("204-http://foo.com"),
          url: "http://foo.com"
        }
        expect(DeliveryLink.find(204).click_events.count).to eq 0
      end
    end

    it "404S when the wrong id is used" do
      expect do
        get :click, params: {
          delivery_link_id: 122,
          hash: "a5ff8760c7cf5763a4008c338d617f71542e362f"
        }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "4040S when the wrong hash is used" do
      expect do
        get :click, params: { delivery_link_id: 204, hash: "123" }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
