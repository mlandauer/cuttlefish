require "spec_helper"

describe HashId do
  it ".hash" do
    expect(HashId.hash(15)).to eq "c4fbdefa0dd07f5dccebf5d6adfaeab278ed7285"
  end

  describe ".valid?" do
    it { expect(HashId.valid?(15, "c4fbdefa0dd07f5dccebf5d6adfaeab278ed7285")).to be_truthy }
    it { expect(HashId.valid?(15, "this hash is wrong")).to be_falsy }
    it { expect(HashId.valid?(14, "c4fbdefa0dd07f5dccebf5d6adfaeab278ed7285")).to be_falsy }
  end
end
