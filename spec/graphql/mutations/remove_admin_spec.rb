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
  let(:current_admin) { create(:admin, team: team_one) }
  let(:admin) { create(:admin, team: team_one) }
  let(:team_one) { create(:team) }
  let(:team_two) { create(:team) }

  it "removes an admin" do
    admin
    current_admin
    expect { result }.to change { Admin.count }.by(-1)
  end

  it "returns the deleted admin" do
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

    it "returns nil for the result and an error" do
      expect(result).to eq(
        "data" => { "removeAdmin" => nil },
        "errors" => [{
          "message" => "We couldn't find what you were looking for",
          "locations" => [{ "line" => 2, "column" => 3 }],
          "path" => ["removeAdmin"],
          "extensions" => { "type" => "NOT_FOUND" }
        }]
      )
    end
  end

  context "trying to remove an admin in another team" do
    let(:admin) { create(:admin, team: team_two) }

    it "returns nil for the result and an error" do
      expect(result.to_h).to eq(
        "data" => { "removeAdmin" => nil },
        "errors" => [{
          "message" => "Not authorized to access Mutation.removeAdmin",
          "locations" => [{ "line" => 2, "column" => 3 }],
          "path" => ["removeAdmin"],
          "extensions" => { "type" => "NOT_AUTHORIZED" }
        }]
      )
    end
  end
end
