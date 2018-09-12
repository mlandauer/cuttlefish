require 'spec_helper'

describe InvitationPolicy do
  subject { InvitationPolicy.new(user, nil) }

  context "normal user" do
    let(:user) { FactoryBot.create(:admin)}

    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:update)  }

    context "in read only mode" do
      before :each do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) { true }
      end
      it { is_expected.not_to permit(:create) }
      it { is_expected.not_to permit(:update)  }
    end
  end
end
