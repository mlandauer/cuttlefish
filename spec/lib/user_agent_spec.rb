# frozen_string_literal: true

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
    let(:u) do
      UserAgentTest.new(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) " \
        "AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D257"
      )
    end

    it { expect(u.calculate_ua_family).to eq "Mobile Safari" }
    it { expect(u.calculate_ua_version).to eq "7.1.2" }
    it { expect(u.calculate_os_family).to eq "iOS" }
    it { expect(u.calculate_os_version).to eq "7.1.2" }
  end

  context "Google image proxy for Gmail" do
    let(:u) do
      UserAgentTest.new(
        "Mozilla/5.0 (Windows NT 5.1; rv:11.0) Gecko Firefox/11.0 " \
        "(via ggpht.com GoogleImageProxy)"
      )
    end

    it { expect(u.calculate_ua_family).to eq "Gmail" }
    # Not quite sure what to do with these values below
    it { expect(u.calculate_ua_version).to be_nil }
    it { expect(u.calculate_os_family).to be_nil }
    it { expect(u.calculate_os_version).to be_nil }
  end
end
