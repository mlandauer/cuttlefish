require "spec_helper"

describe Filters::Base do
  let(:mail) {
    Mail.new do
      body "Some content"
    end
  }
  let(:delivery) { double }
  let(:filter) { Filters::Base.new(delivery) }

  describe "#filter" do
    it { filter.filter_mail(mail).should == mail}
  end
end
