# frozen_string_literal: true

describe Mutations::RemoveAdmin do
  let(:result) do
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end
  let(:query_string) do
    <<~GRAPHQL
      mutation ($id: ID!) {
        removeAdmin(id: $id) {
          admin {
            id
          }
        }
      }
    GRAPHQL
  end
  let(:context) { { current_admin: current_admin } }
  let(:variables) { { id: admin.id } }
  let(:current_admin) { FactoryBot.create(:admin, team: team_one) }
  let(:admin) { FactoryBot.create(:admin, team: team_one) }
  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  it "should remove an admin" do
    admin
    current_admin
    expect { result }.to change { Admin.count }.by(-1)
  end

  it "should return the deleted admin" do
    expect(result).to eq(
      "data" => {
        "removeAdmin" => {
          "admin" => {
            "id" => admin.id.to_s
          }
        }
      }
    )
  end

  context "trying to remove non-existent admin" do
    before(:each) { admin.destroy! }

    it "should return nil for the result" do
      expect(result).to eq(
        "data" => {
          "removeAdmin" => {
            "admin" => nil
          }
        }
      )
    end
  end

  context "trying to remove an admin in another team" do
    let(:admin) { FactoryBot.create(:admin, team: team_two) }

    it "should return nil for the result" do
      expect(result).to eq(
        "data" => {
          "removeAdmin" => {
            "admin" => nil
          }
        }
      )
    end
  end
end
