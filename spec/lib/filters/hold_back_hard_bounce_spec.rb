require "spec_helper"

describe Filters::HoldBackHardBounce do
  let(:delivery) { mock(from: "foo@foo.com", to: ["bar@foo.com"], data: "my original data") }
  let(:filter) { Filters::HoldBackHardBounce.new(delivery) }

  describe "#from" do
    it { filter.from.should == "foo@foo.com" }
  end

  describe "#to" do
    it { filter.to.should == ["bar@foo.com"]}
  end

  describe "#data" do
    it { filter.data.should == "my original data"}
  end

  describe "#send?" do
    context "an address where an email was succesfully sent before" do
      before :each do
        delivery.stub_chain(:address, :status).and_return("delivered")
      end
      it { filter.send?.should be_true }
    end

    context "an address where an email hard_bounced most recently" do
      before :each do
        delivery.stub_chain(:address, :status).and_return("hard_bounce")
      end
      it { filter.send?.should be_false }
    end
  end

end
