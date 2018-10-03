# frozen_string_literal: true

require 'spec_helper'

describe EmailsHelper, type: :helper do
  describe ".bootstrap_status_class" do
    it { expect(helper.bootstrap_status_class("delivered")).to eq "success"}
    it { expect(helper.bootstrap_status_class("soft_bounce")).to eq "warning"}
    it { expect(helper.bootstrap_status_class("hard_bounce")).to eq "error"}
    it { expect(helper.bootstrap_status_class("sent")).to eq "success"}
    it { expect {helper.bootstrap_status_class("foo") }.to raise_error("Unknown status") }
  end

  describe ".delivered_label" do
    it { expect(helper.delivered_label("delivered")).to eq '<span class="label label-success">Delivered</span>' }
    it { expect(helper.delivered_label("soft_bounce")).to eq '<span class="label label-warning">Soft bounce</span>' }
    it { expect(helper.delivered_label("hard_bounce")).to eq '<span class="label label-important">Hard bounce</span>' }
    it { expect(helper.delivered_label("sent")).to eq '<span class="label label-success">Sent</span>' }
    it { expect {helper.delivered_label("foo")}.to raise_error("Unknown status") }
  end
end
