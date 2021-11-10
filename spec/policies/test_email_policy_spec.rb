# frozen_string_literal: true

require "spec_helper"

describe TestEmailPolicy do
  subject { described_class.new(user, nil) }

  context "when normal user" do
    let(:user) { create(:admin) }

    it { is_expected.to permit(:new) }
    it { is_expected.to permit(:create) }

    context "when in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode).and_return(true)
      end

      it { is_expected.not_to permit(:new) }
      it { is_expected.not_to permit(:create) }
    end
  end

  context "when unauthenticated user" do
    let(:user) { nil }

    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:create) }
  end
end
