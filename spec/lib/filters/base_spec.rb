require "spec_helper"

describe Filters::Base do
  let(:mail) {
    Mail.new do
      body "Some content"
    end
  }
  let(:filter) { Filters::Base.new }

  describe "#filter" do
    it { expect(filter.filter_mail(mail)).to eq mail}
  end
end
