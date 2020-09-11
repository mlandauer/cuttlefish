# frozen_string_literal: true

require "spec_helper"

describe DenyListServices::Destroy do
  let(:team) { create(:team) }
  let(:app) { create(:app, team: team) }
  let(:current_admin) { create(:admin, team: team) }
  let(:deny_list) { create(:app_deny_list, app: app) }
  let(:destroy_deny_list) do
    DenyListServices::Destroy.call(
      current_admin: current_admin, id: deny_list.id
    )
  end

  it "should remove a deny list entry" do
    deny_list
    expect { destroy_deny_list }.to change { AppDenyList.count }.by(-1)
  end

  it "should return the deleted entry" do
    expect(destroy_deny_list.result).to eq deny_list
  end

  context "entry does not exist" do
    before(:each) { deny_list.destroy! }

    it "should error" do
      expect { destroy_deny_list }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "does not have permission" do
    let(:deny_list_policy) { double }
    before :each do
      expect(AppDenyListPolicy).to receive(:new) { deny_list_policy }
      expect(deny_list_policy).to receive(:destroy?) { false }
    end

    it "should error" do
      expect { destroy_deny_list }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
