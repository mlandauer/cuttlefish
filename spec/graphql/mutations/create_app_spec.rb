# frozen_string_literal: true

describe Mutations::CreateApp do
  let(:result) do
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end
  let(:query_string) do
    <<~GRAPHQL
      mutation ($name: String!) {
        createApp(attributes: { name: $name }) {
          app {
            name
          }
          errors {
            path
            message
            type
          }
        }
      }
    GRAPHQL
  end
  let(:context) { { current_admin: current_admin } }
  let(:name) { "An App" }
  let(:variables) { { name: name } }
  let(:current_admin) { create(:admin) }

  it "does not return any errors" do
    expect(result["errors"]).to be_nil
  end

  it "creates an app" do
    expect { result }.to change(App, :count).by(1)
  end

  it "returns the created app" do
    expect(result["data"]["createApp"]).to eq(
      "app" => { "name" => name },
      "errors" => []
    )
  end

  context "when user does not have permission" do
    let(:app_policy) { double }

    before do
      expect(AppPolicy).to receive(:new) { app_policy }
      expect(app_policy).to receive(:create?).and_return(false)
    end

    it "returns an error" do
      expect(result.to_h).to eq(
        "data" => { "createApp" => nil },
        "errors" => [{
          "message" => "Not authorized to access Mutation.createApp",
          "locations" => [{ "line" => 2, "column" => 3 }],
          "path" => ["createApp"],
          "extensions" => { "type" => "NOT_AUTHORIZED" }
        }]
      )
    end
  end

  context "with invalid name" do
    let(:name) { "sd^&" }

    it "returns a nil app and a validation error" do
      expect(result["data"]["createApp"]).to eq(
        "app" => nil,
        "errors" => [{
          "message" => "only letters, numbers, spaces and underscores",
          "type" => "INVALID",
          "path" => %w[attributes name]
        }]
      )
    end
  end
end
