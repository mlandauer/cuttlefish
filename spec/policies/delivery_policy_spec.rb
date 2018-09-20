require 'spec_helper'

describe DeliveryPolicy do
  subject { DeliveryPolicy.new(user, delivery) }

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  let(:app) { FactoryBot.create(:app, team: team_one) }
  let(:email) { FactoryBot.create(:email, app: app)}
  let(:delivery) { FactoryBot.create(:delivery, email: email) }

  context "normal user in team one" do
    let(:user) { FactoryBot.create(:admin, team: team_one)}
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it 'is included in the scope' do
      delivery
      expect(DeliveryPolicy::Scope.new(user, Delivery.all).resolve).to include(delivery)
    end
  end

  context "unauthenticated user" do
    let(:user) { nil }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it 'is included in the scope' do
      delivery
      expect(DeliveryPolicy::Scope.new(user, Delivery.all).resolve).to be_empty
    end
  end

  context "normal user in team two" do
    let(:user) { FactoryBot.create(:admin, team: team_two)}
    it { is_expected.not_to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it 'is not included in the scope' do
      delivery
      expect(DeliveryPolicy::Scope.new(user, Delivery.all).resolve).to_not include(delivery)
    end
  end

  context "super admin in team two" do
    let(:user) { FactoryBot.create(:admin, team: team_two, super_admin: true)}
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it 'is included in the scope' do
      delivery
      expect(DeliveryPolicy::Scope.new(user, Delivery.all).resolve).to include(delivery)
    end
  end
end
