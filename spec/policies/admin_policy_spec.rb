# frozen_string_literal: true

require "spec_helper"

describe AdminPolicy do
  subject { described_class.new(user, admin) }

  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }

  let(:admin) { create(:admin, team: team_one) }

  context "when not authenticated" do
    let(:user) { nil }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }

    it "has an empty scope" do
      admin
      expect(AdminPolicy::Scope.new(user, Admin).resolve).to be_empty
    end
  end

  context "with normal user in team one" do
    let(:user) { create(:admin, team: team_one) }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:destroy) }

    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }

    it "is in scope" do
      admin
      expect(AdminPolicy::Scope.new(user, Admin).resolve).to include(admin)
    end

    context "when in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode).and_return(true)
      end

      it { is_expected.not_to permit(:destroy) }
    end

    context "when user and admin are the same" do
      let(:user) { admin }

      it { is_expected.to permit(:destroy) }
    end
  end

  context "when normal user in team two" do
    let(:user) { create(:admin, team: team_two) }

    it { is_expected.to permit(:index) }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }

    it "is not in scope" do
      admin
      expect(AdminPolicy::Scope.new(user, Admin).resolve).not_to include(admin)
    end
  end
end
