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

  # This is the same for any unrecognised method
  describe "#id" do
    it "should return the id of the original input" do
      a = mock(:id => "123")
      b = DeliveryFilter.new(a)
      b.id.should == "123"
    end

    it "should return the id of the input even when several filters are chained together" do
      a = mock(:id => "123")
      b = DeliveryFilter.new(a)
      c = DeliveryFilter.new(b)
      c.id.should == "123"
    end
  end
end