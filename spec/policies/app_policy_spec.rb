# frozen_string_literal: true

require "spec_helper"

describe AppPolicy do
  # TODO: Test effect of read only mode

  subject { AppPolicy.new(user, app) }

  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }

  let(:app) { create(:app, team: team_one) }

  context "not authenticated" do
    let(:user) { nil }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:dkim) }
    it { is_expected.not_to permit(:toggle_dkim) }

    it "has empty scope" do
      app
      expect(AppPolicy::Scope.new(user, App).resolve).to eq []
    end
  end

  context "normal user in team one" do
    let(:user) { create(:admin, team: team_one) }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:destroy) }
    it { is_expected.to permit(:dkim) }
    it { is_expected.to permit(:toggle_dkim) }

    it "is in scope" do
      app
      expect(AppPolicy::Scope.new(user, App).resolve).to include(app)
    end
  end

  context "normal user in team two" do
    let(:user) { create(:admin, team: team_two) }

    it { is_expected.not_to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:dkim) }
    it { is_expected.not_to permit(:toggle_dkim) }

    it "is not in scope" do
      app
      expect(AppPolicy::Scope.new(user, App).resolve).not_to include(app)
    end
  end

  context "super admin in team two" do
    let(:user) { create(:admin, team: team_two, site_admin: true) }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
    it { is_expected.not_to permit(:dkim) }
    it { is_expected.not_to permit(:toggle_dkim) }
    # This is so that for super admins you don't by default see all the apps
    # in the apps list. However, you can still view individual ones (and the
    # emails contained within) if you really need to do by going to the team
    # list

    it "is not in scope" do
      app
      expect(AppPolicy::Scope.new(user, App).resolve).not_to include(app)
    end

    context "cuttlefish app" do
      let(:app) { App.cuttlefish }

      it { is_expected.to permit(:show) }
      it { is_expected.to permit(:create) }
      it { is_expected.to permit(:new) }
      it { is_expected.not_to permit(:update)  }
      it { is_expected.not_to permit(:edit)    }
      it { is_expected.not_to permit(:destroy) }
      it { is_expected.to permit(:dkim) }
      it { is_expected.to permit(:toggle_dkim) }

      it "is not in scope" do
        app
        expect(AppPolicy::Scope.new(user, App).resolve).not_to include(app)
      end
    end
  end
end
