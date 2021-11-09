# frozen_string_literal: true

require "spec_helper"

describe HashId do
  it ".hash" do
    expect(described_class.hash("15")).to eq "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4"
  end

  describe ".valid?" do
    it {
      expect(
        described_class.valid?("15", "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4")
      ).to be_truthy
    }

    it {
      expect(
        described_class.valid?("15", "this hash is wrong")
      ).to be_falsy
    }

    it {
      expect(
        described_class.valid?("14", "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4")
      ).to be_falsy
    }
  end
end
