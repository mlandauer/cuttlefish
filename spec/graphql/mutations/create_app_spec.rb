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

  context "user does not have permission" do
    let(:app_policy) { double }
    before :each do
      expect(AppPolicy).to receive(:new) { app_policy }
      expect(app_policy).to receive(:create?) { false }
    end

    it "should return an error" do
      expect(result['data']['createApp']).to eq ({
        'app' => nil,
        'errors' => [{
          "message" => "You don't have permissions to do this",
          "type" => "PERMISSION",
          "path" => []
        }]
      })
    end
  end

  context "invalid name" do
    let(:name) { 'sd^&' }

    it "should return a nil app and a validation error" do
      expect(result['data']['createApp']).to eq ({
        'app' => nil,
        'errors' => [{
          "message" => "only letters, numbers, spaces and underscores",
          "type" => "INVALID",
          "path" => ["attributes", "name"]
        }]
      })
    end
  end
end
