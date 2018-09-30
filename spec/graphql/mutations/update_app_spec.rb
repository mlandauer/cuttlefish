describe Mutations::UpdateApp do
  let(:result) {
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  }

  let(:query_string) {
    <<-EOF
    mutation ($id: ID!, $attributes: AppAttributes!) {
      updateApp(id: $id, attributes: $attributes) {
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
    EOF
  }
  let(:attributes) { {
    'name' => name,
    'openTrackingEnabled' => true,
    'clickTrackingEnabled' => true,
    'customTrackingDomain' => nil,
    'fromDomain' => nil
  } }
  let(:context) { { current_admin: current_admin }}
  let(:name) { 'An updated App' }
  let(:variables) { { id: app.id, attributes: attributes } }
  let(:current_admin) { FactoryBot.create(:admin, team: team) }
  let(:app) { create(:app, team: team) }
  let(:team) { create(:team) }

  it 'should not return any errors and return the updated app' do
    expect(result).to eq ({
      "data" => {
        "updateApp" => {
          "app" => { "name" => "An updated App" },
          "errors" => []
        }
      }
    })
  end

  it "should update the name" do
    result
    app.reload
    expect(app.name).to eq name
  end
end
