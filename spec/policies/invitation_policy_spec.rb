# frozen_string_literal: true

require "spec_helper"

describe InvitationPolicy do
  subject { described_class.new(user, nil) }

  context "normal user" do
    let(:user) { create(:admin) }

    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:update) }

    context "in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode).and_return(true)
      end

      it { is_expected.not_to permit(:create) }
      it { is_expected.not_to permit(:update) }
    end
  end

  context "unauthenticated user" do
    let(:user) { nil }

    it { is_expected.not_to permit(:create) }
    # Because this is for accepting an invitation which is unauthenticated
    it { is_expected.to permit(:update) }
  end
end
