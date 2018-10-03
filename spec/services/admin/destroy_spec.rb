# frozen_string_literal: true

require 'spec_helper'

describe Admin::Destroy do
  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }
  let(:admin) { create(:admin, team: team_one) }
  let(:current_admin) { create(:admin, team: team_one) }
  let(:remove_admin) { Admin::Destroy.call(current_admin: current_admin, id: admin.id) }

  it "should remove an admin" do
    admin
    current_admin
    expect { remove_admin }.to change { Admin.count }.by(-1)
  end

  it "should return the removed admin as the result" do
    expect(remove_admin.result).to eq admin
  end

  it "should be successful" do
    expect(remove_admin.success?).to be true
  end

  it "should not have an error message" do
    expect(remove_admin.error).to be_nil
  end

  context "admin is in another team" do
    let(:admin) { create(:admin, team: team_two) }

    it "should do nothing" do
      admin
      current_admin
      expect { remove_admin }.to_not change { Admin.count }
    end

    it "should return nil" do
      expect(remove_admin.result).to be_nil
    end

    it "should not be successful" do
      expect(remove_admin.success?).to be false
    end

    it "should give an error message" do
      expect(remove_admin.error).to eq "You can't remove the admin with this id"
    end
  end

  context "admin doesn't exist" do
    before(:each) { admin.destroy! }

    it "should do nothing" do
      admin
      current_admin
      expect { remove_admin }.to_not change { Admin.count }
    end

    it "should return nil" do
      expect(remove_admin.result).to be_nil
    end

    it "should not be successful" do
      expect(remove_admin.success?).to be false
    end

    it "should give an error message" do
      expect(remove_admin.error).to eq "You can't remove the admin with this id"
    end
  end
end
