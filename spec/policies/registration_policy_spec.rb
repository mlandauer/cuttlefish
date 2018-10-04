# frozen_string_literal: true

require "spec_helper"

describe RegistrationPolicy do
  subject { RegistrationPolicy.new(user, nil) }

  context "normal user" do
    let(:user) { FactoryBot.create(:admin) }

    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:edit) }
    it { is_expected.to permit(:destroy) }

    context "in read only mode" do
      before :each do
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
