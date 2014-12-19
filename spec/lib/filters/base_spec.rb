require "spec_helper"

describe Filters::Base do
  let(:delivery) { double(from: "foo@foo.com", to: ["bar@foo.com"], data: "my original data") }
  let(:filter) { Filters::Base.new(delivery) }

  describe "#data" do
    it { filter.filter(delivery.data).should == "my original data"}
  end
end
