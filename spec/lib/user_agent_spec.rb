require "spec_helper"

class UserAgentTest
  attr_accessor :user_agent
  include UserAgent

  def initialize(user_agent)
    @user_agent = user_agent
  end
end

describe UserAgent do
  context "Mobile Safari / iOS" do
    let(:u) { UserAgentTest.new("Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257") }
    it { expect(u.ua_family).to eq "Mobile Safari" }
    it { expect(u.ua_version).to eq "7.1.2" }
    it { expect(u.os_family).to eq "iOS" }
    it { expect(u.os_version).to eq "7.1.2" }
  end
end
