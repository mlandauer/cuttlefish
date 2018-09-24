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
      }
    }
    EOF
  }
  let(:context) { { current_admin: current_admin }}
  let(:variables) { { name: 'An App' } }
  let(:current_admin) { FactoryBot.create(:admin) }

  it 'should not return any errors' do
    expect(result['errors']).to be_nil
  end

  it "should create an app" do
    expect { result }.to change { App.count }.by(1)
  end

  it "should return the created app" do
    expect(result['data']['createApp']['app']['name']).to eq 'An App'
  end
end
