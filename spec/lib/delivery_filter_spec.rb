require "spec_helper"

describe DeliveryFilter do
  let(:delivery) { mock(from: "foo@foo.com", to: ["bar@foo.com"], data: "my original data") }
  let(:filter) { DeliveryFilter.new(delivery) }

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
    it { filter.send?.should be_true}

    it "should be composable" do
      delivery.stub(:send?).and_return(false)
      filter.send?.should be_false
    end
  end

  describe "#original" do
    it "should return the original input" do
      a = mock
      b = DeliveryFilter.new(a)
      b.original.should == a
    end

    it "should return the original input even when several filters are chained together" do
      a = mock
      b = DeliveryFilter.new(a)
      c = DeliveryFilter.new(b)
      c.original.should == a
    end
  end
end