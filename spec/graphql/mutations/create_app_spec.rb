describe Mutations::CreateApp do
  let(:result) {
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  }
  let(:query_string) {
    <<-EOF
    mutation ($name: String!) {
      createApp(name: $name) {
        app {
          name
        }
        errors {
          message
          path
        }
      }
    }
    EOF
  }
  let(:context) { { current_admin: current_admin }}
  let(:name) { 'An App' }
  let(:variables) { { name: name } }
  let(:current_admin) { FactoryBot.create(:admin) }

  it 'should not return any errors' do
    expect(result['errors']).to be_nil
  end

  it "should create an app" do
    expect { result }.to change { App.count }.by(1)
  end

  it "should return the created app" do
    expect(result['data']['createApp']).to eq ({
      'app' => { 'name' => name },
      'errors' => []
    })
  end

  pending "shouldn't do anything if it doesn't have permission"

  context "invalid name" do
    let(:name) { 'sd^&' }

    it "should return a nil app and a validation error" do
      expect(result['data']['createApp']).to eq ({
        'app' => nil,
        'errors' => [{
          "message" => "Only letters, numbers, spaces and underscores",
          "path" => ["attributes", "name"]
        }]
      })
    end
  end
end
