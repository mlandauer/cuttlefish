require 'spec_helper'

describe AdminPolicy do
  subject { AdminPolicy.new(user, admin) }

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  let(:admin) { FactoryBot.create(:admin, team: team_one) }

  context "not authenticated" do
    let(:user) { nil }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:index) }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }

    it 'should have an empty scope' do
      admin
      expect(AdminPolicy::Scope.new(user, Admin).resolve).to be_empty
    end
  end

  context "normal user in team one" do
    let(:user) { FactoryBot.create(:admin, team: team_one)}
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:index) }
    it { is_expected.to permit(:destroy) }

    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }

    it 'should be in scope' do
      admin
      expect(AdminPolicy::Scope.new(user, Admin).resolve).to include(admin)
    end

    context "in read only mode" do
      before :each do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) { true }
      end
      it { is_expected.not_to permit(:destroy) }
    end

    context "user and admin are the same" do
      let(:user) { admin }
      it { is_expected.not_to permit(:destroy) }
    end
  end

  context "normal user in team two" do
    let(:user) { FactoryBot.create(:admin, team: team_two)}
    it { is_expected.to permit(:index) }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }

    it 'should not be in scope' do
      admin
      expect(AdminPolicy::Scope.new(user, Admin).resolve).to_not include(admin)
    end
  end
end
