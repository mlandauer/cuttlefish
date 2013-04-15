require "spec_helper"

describe HoldBackHardBounceFilter do
  let(:delivery) { mock }

  describe "#send?" do
    context "an address where an email was succesfully sent before" do
      before :each do
        delivery.stub_chain(:address, :status).and_return("delivered")
      end
      it { HoldBackHardBounceFilter.new(delivery).send?.should be_true }
    end

    context "an address where an email hard_bounced most recently" do
      before :each do
        delivery.stub_chain(:address, :status).and_return("hard_bounce")
      end
      it { HoldBackHardBounceFilter.new(delivery).send?.should be_false }
    end
  end

end