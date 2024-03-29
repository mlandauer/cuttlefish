# frozen_string_literal: true

require "spec_helper"

describe RegistrationPolicy do
  subject { described_class.new(user, nil) }

  context "when not logged in" do
    let(:user) { nil }

    context "when no pre-existing users" do
      it { is_expected.to permit(:create) }
    end

    context "when one pre-existing user" do
      before { create(:admin) }

      it { is_expected.not_to permit(:create) }
    end
  end

  context "when logged in" do
    let(:user) { create(:admin) }

    it { is_expected.not_to permit(:create) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:edit) }
    it { is_expected.to permit(:destroy) }

    context "when in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode).and_return(true)
      end

      it { is_expected.not_to permit(:create) }
      it { is_expected.not_to permit(:update) }
      it { is_expected.not_to permit(:edit) }
      it { is_expected.not_to permit(:destroy) }
    end
  end
end
