# frozen_string_literal: true

require "spec_helper"

describe TeamPolicy do
  subject { TeamPolicy.new(user, team_one) }

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  context "normal user in team one" do
    let(:user) { FactoryBot.create(:admin, team: team_one) }
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:edit) }

    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:invite) }
    it { is_expected.not_to permit(:destroy) }

    it "should have an empty scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to be_empty
    end
  end

  context "unauthenticated user" do
    let(:user) { nil }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:edit) }
    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:invite) }
    it { is_expected.not_to permit(:destroy) }

    it "should have an empty scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to be_empty
    end
  end

  context "normal user in team two" do
    let(:user) { FactoryBot.create(:admin, team: team_two) }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:edit) }

    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:invite) }
    it { is_expected.not_to permit(:destroy) }

    it "should have an empty scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to be_empty
    end
  end

  context "super admin in team two" do
    let(:user) { FactoryBot.create(:admin, team: team_two, site_admin: true) }
    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:invite) }

    it "should have all teams in scope" do
      expect(TeamPolicy::Scope.new(user, Team).resolve).to include(team_one, team_two)
    end

    context "in read only mode" do
      before :each do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) { true }
      end
      it { is_expected.not_to permit(:invite) }
    end
  end
end
