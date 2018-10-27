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

  it "should not return any errors" do
    expect(result["errors"]).to be_nil
  end

  it "should create an app" do
    expect { result }.to change { App.count }.by(1)
  end

  it "should return the created app" do
    expect(result["data"]["createApp"]).to eq(
      "app" => { "name" => name },
      "errors" => []
    )
  end

  context "user does not have permission" do
    let(:app_policy) { double }
    before :each do
      expect(AppPolicy).to receive(:new) { app_policy }
      expect(app_policy).to receive(:create?) { false }
    end

    it "should return an error" do
      expect(result).to eq(
        "data" => { "createApp" => nil },
        "errors" => [{
          "message" => "You don't have permissions to do this",
          "locations" => [{ "line" => 2, "column" => 3 }],
          "path" => ["createApp"],
          "extensions" => { "type" => "NOT_AUTHORIZED" }
        }]
      )
    end
  end

  context "invalid name" do
    let(:name) { "sd^&" }

    it "should return a nil app and a validation error" do
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
