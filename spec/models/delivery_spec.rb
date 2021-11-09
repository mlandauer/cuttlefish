# frozen_string_literal: true

require "spec_helper"

describe Delivery do
  let(:delivery) { create(:delivery) }

  describe "#status" do
    context "delivery is sent" do
      before do
        delivery.update_attributes(sent: true)
      end

      it "is delivered if the status is sent" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(
          dsn: "2.0.0",
          time: Time.now,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        expect(delivery.status).to eq "delivered"
      end

      it "is soft_bounce if the status was deferred" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(
          dsn: "4.3.0",
          time: Time.now,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        expect(delivery.status).to eq "soft_bounce"
      end

      it "is sent if there is no log line" do
        expect(delivery.status).to eq "sent"
      end

      it "is delivered if most recent status was a succesful delivery" do
        # TODO: Replace with factory_girl
        delivery.postfix_log_lines.create(
          dsn: "4.3.0",
          time: 1.hour.ago,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        delivery.postfix_log_lines.create(
          dsn: "2.0.0",
          time: 5.minutes.ago,
          relay: "",
          delay: "",
          delays: "",
          extended_status: ""
        )
        expect(delivery.status).to eq "delivered"
      end
    end

    it "is not_sent if the nothing's been sent yet" do
      expect(delivery.status).to eq "not_sent"
    end

    it "has a return path" do
      expect(delivery.return_path).to eq "bounces@cuttlefish.oaf.org.au"
    end
  end
end
