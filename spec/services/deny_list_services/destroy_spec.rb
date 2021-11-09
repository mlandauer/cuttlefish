# frozen_string_literal: true

require "spec_helper"

describe DenyListServices::Destroy do
  let(:team) { create(:team) }
  let(:app) { create(:app, team: team) }
  let(:current_admin) { create(:admin, team: team) }
  let(:deny_list) { create(:deny_list, app: app) }
  let(:destroy_deny_list) do
    DenyListServices::Destroy.call(
      current_admin: current_admin, id: deny_list.id
    )
  end

  it "removes a deny list entry" do
    deny_list
    expect { destroy_deny_list }.to change { DenyList.count }.by(-1)
  end

  it "returns the deleted entry" do
    expect(destroy_deny_list.result).to eq deny_list
  end

  context "entry does not exist" do
    before(:each) { deny_list.destroy! }

    it "errors" do
      expect { destroy_deny_list }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "does not have permission" do
    let(:deny_list_policy) { double }
    before :each do
      expect(DenyListPolicy).to receive(:new) { deny_list_policy }
      expect(deny_list_policy).to receive(:destroy?) { false }
    end

    it "errors" do
      expect { destroy_deny_list }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
