# frozen_string_literal: true

require "spec_helper"

describe TestEmailPolicy do
  subject { TestEmailPolicy.new(user, nil) }

  context "normal user" do
    let(:user) { create(:admin) }

    it { is_expected.to permit(:new) }
    it { is_expected.to permit(:create) }

    context "in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) {
          true
        }
      end
      it { is_expected.not_to permit(:new) }
      it { is_expected.not_to permit(:create) }
    end
  end

  context "unauthenticated user" do
    let(:user) { nil }

    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:create) }
  end
end
