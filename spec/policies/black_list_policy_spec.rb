require 'spec_helper'

describe BlackListPolicy do
  subject { BlackListPolicy.new(user, black_list) }

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  let(:black_list) { FactoryBot.create(:black_list, team: team_one) }

  context "normal user in team one" do
    let(:user) { FactoryBot.create(:admin, team: team_one)}
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:destroy) }
    it 'should be in scope' do
      black_list
      expect(BlackListPolicy::Scope.new(user, BlackList).resolve).to include(black_list)
    end

    context "in read only mode" do
      before :each do
        allow(Rails.configuration).to receive(:cuttlefish_read_only_mode) { true }
      end
      it { is_expected.not_to permit(:destroy) }
    end
  end

  context "normal user in team two" do
    let(:user) { FactoryBot.create(:admin, team: team_two)}
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:destroy) }
    it 'should not be in scope' do
      black_list
      expect(BlackListPolicy::Scope.new(user, BlackList).resolve).to_not include(black_list)
    end
  end
end
