require "spec_helper"

describe HashId do
  it ".hash" do
    HashId.hash(15).should == "bd0dce790c91139b20bf406a0357359c65b88e3c"
  end

  describe ".valid?" do
    it { HashId.valid?(15, "bd0dce790c91139b20bf406a0357359c65b88e3c").should be_true }
    it { HashId.valid?(15, "this hash is wrong").should be_false }
    it { HashId.valid?(14, "bd0dce790c91139b20bf406a0357359c65b88e3c").should be_false }
  end
end