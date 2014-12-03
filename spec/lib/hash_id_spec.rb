require "spec_helper"

describe HashId do
  it ".hash" do
    HashId.hash(15).should == "c4fbdefa0dd07f5dccebf5d6adfaeab278ed7285"
  end

  describe ".valid?" do
    it { HashId.valid?(15, "c4fbdefa0dd07f5dccebf5d6adfaeab278ed7285").should be_true }
    it { HashId.valid?(15, "this hash is wrong").should be_false }
    it { HashId.valid?(14, "c4fbdefa0dd07f5dccebf5d6adfaeab278ed7285").should be_false }
  end
end
