require "spec_helper"

describe HashId2 do
  it ".hash" do
    expect(HashId2.hash("15")).to eq "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4"
  end


  describe ".valid?" do
    it { expect(HashId2.valid?("15", "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4")).to be_truthy }
    it { expect(HashId2.valid?("15", "this hash is wrong")).to be_falsy }
    it { expect(HashId2.valid?("14", "29a6fc331a2dc6ebe86a055b91dfb19f6537f6c4")).to be_falsy }
  end
end
