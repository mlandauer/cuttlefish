require 'spec_helper'

describe RemoveAdmin do
  let(:admin) { create(:admin) }

  it "should remove an admin" do
    admin
    expect { RemoveAdmin.call(id: admin.id) }.to change { Admin.count }.by(-1)
  end
end
