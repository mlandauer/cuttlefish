# frozen_string_literal: true

require "spec_helper"

describe RegistrationPolicy do
  subject { RegistrationPolicy.new(user, nil) }

  context "not logged in" do
    let(:user) { nil }

    context "no pre-existing users" do
      it { is_expected.to permit(:create) }
    end

    context "one pre-existing user" do
      before { create(:admin) }

      it { is_expected.not_to permit(:create) }
    end
  end

  context "logged in" do
    let(:user) { create(:admin) }

    it { is_expected.not_to permit(:create) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:edit) }
    it { is_expected.to permit(:destroy) }

    context "in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) {
          true
        }
      end
      it { is_expected.not_to permit(:create) }
      it { is_expected.not_to permit(:update) }
      it { is_expected.not_to permit(:edit) }
      it { is_expected.not_to permit(:destroy) }
    end
  end
end
