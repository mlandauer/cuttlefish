# frozen_string_literal: true

require "spec_helper"

describe HashId do
  it ".hash" do
    expect(described_class.hash("15")).to eq "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4"
  end

  describe ".valid?" do
    it {
      expect(
        described_class
      ).to be_valid("15", "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4")
    }

    it {
      expect(
        described_class
      ).not_to be_valid("15", "this hash is wrong")
    }

    it {
      expect(
        described_class
      ).not_to be_valid("14", "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4")
    }
  end
end
