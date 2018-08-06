describe CuttlefishSchema do
  let(:context) { { current_admin: admin }}
  let(:variables) { {} }
  let(:result) {
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  }

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  let(:admin) { FactoryBot.create(:admin, team: team_one) }
  let(:app) { FactoryBot.create(:app, team: team_one) }
  let(:email) { FactoryBot.create(:email, app: app)}
  let(:delivery) { FactoryBot.create(:delivery, email: email) }

  before :each do
    delivery
  end

  describe "email" do
    let(:query_string) { 'query($id: ID!) { email(id: $id) { id } }' }
    let(:variables) { { id: delivery.id } }

    it "should return a valid result" do
      expect(result['data']['email']['id']).to eq delivery.id.to_s
      expect(result['errors']).to be_nil
    end

    context "with no current user" do
      let(:context) { {} }

      it "should return nil and error" do
        expect(result['data']['email']).to be_nil
        expect(result['errors'].length).to eq 1
        expect(result['errors'][0]['message']).to eq "Need to be authenticated"
      end
    end

    context "with a user in a different team" do
      let(:admin) { FactoryBot.create(:admin, team: team_two) }

      it "should return nil and an error" do
        expect(result['data']['email']).to be_nil
        expect(result['errors'].length).to eq 1
        expect(result['errors'][0]['message']).to eq "An object of type Email was hidden due to permissions"
      end
    end

    context "query for non existing email" do
      let(:variables) { { id: (delivery.id + 1) } }

      it "should return nil and error" do
        expect(result['data']['email']).to be_nil
        expect(result['errors'].length).to eq 1
        expect(result['errors'][0]['message']).to eq "Email doesn't exist"
      end
    end
  end
end
