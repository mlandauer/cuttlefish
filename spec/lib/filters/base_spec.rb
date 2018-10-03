# frozen_string_literal: true

require "spec_helper"

describe Filters::Base do
  let(:mail) do
    Mail.new do
      body "Some content"
    end
  end
  let(:filter) { Filters::Base.new }

  describe "#filter" do
    it { expect(filter.filter_mail(mail)).to eq mail }
  end
end
