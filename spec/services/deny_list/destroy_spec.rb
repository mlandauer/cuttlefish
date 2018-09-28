require 'spec_helper'

describe DenyList::Destroy do
  let(:team) { create(:team) }
  let(:current_admin) { create(:admin, team: team) }
  let(:deny_list) { create(:deny_list, team: team) }
  let(:destroy_deny_list) { DenyList::Destroy.call(current_admin: current_admin, id: deny_list.id) }

  it "should remove a deny list entry" do
    deny_list
    expect { destroy_deny_list }.to change { DenyList.count }.by(-1)
  end

  it "should return the deleted entry" do
    expect(destroy_deny_list.result).to eq deny_list
  end

  context "entry does not exist" do
    before(:each) { deny_list.destroy! }

    it "should return nil" do
      expect(destroy_deny_list.result).to be_nil
    end
  end

  context "does not have permission" do
    let(:deny_list_policy) { double }
    before :each do
      expect(DenyListPolicy).to receive(:new) { deny_list_policy }
      expect(deny_list_policy).to receive(:destroy?) { false }
    end

    it "should return nil" do
      expect(destroy_deny_list.result).to be_nil
    end
  end
end
