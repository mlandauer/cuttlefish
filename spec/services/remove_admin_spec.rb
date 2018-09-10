require 'spec_helper'

describe RemoveAdmin do
  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }
  let(:admin) { create(:admin, team: team_one) }
  let(:current_admin) { create(:admin, team: team_one) }
  let(:remove_admin) { RemoveAdmin.call(current_admin: current_admin, id: admin.id) }

  it "should remove an admin" do
    admin
    current_admin
    expect { remove_admin }.to change { Admin.count }.by(-1)
  end

  it "should be successful" do
    expect(remove_admin.success?).to be true
  end

  context "admin is in another team" do
    let(:admin) { create(:admin, team: team_two) }

    it "should do nothing" do
      admin
      current_admin
      expect { remove_admin }.to_not change { Admin.count }
    end

    it "should not be successful" do
      expect(remove_admin.success?).to be false
    end
  end
end
