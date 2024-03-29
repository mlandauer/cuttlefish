# frozen_string_literal: true

require "spec_helper"

describe TeamPolicy do
  subject { described_class.new(user, team_one) }

  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }

  context "when normal user in team one" do
    let(:user) { create(:admin, team: team_one) }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:edit) }

    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:invite) }
    it { is_expected.not_to permit(:destroy) }

    it "has an empty scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to be_empty
    end
  end

  context "when unauthenticated user" do
    let(:user) { nil }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:edit) }
    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:invite) }
    it { is_expected.not_to permit(:destroy) }

    it "has an empty scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to be_empty
    end
  end

  context "when normal user in team two" do
    let(:user) { create(:admin, team: team_two) }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:edit) }

    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:invite) }
    it { is_expected.not_to permit(:destroy) }

    it "has an empty scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to be_empty
    end
  end

  context "when super admin in team two" do
    let(:user) { create(:admin, team: team_two, site_admin: true) }

    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:invite) }

    it "has all teams in scope" do
      expect(
        TeamPolicy::Scope.new(user, Team).resolve
      ).to include(team_one, team_two)
    end

    context "when in read only mode" do
      before do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode).and_return(true)
      end

      it { is_expected.not_to permit(:invite) }
    end
  end
end
