# frozen_string_literal: true

describe CuttlefishSchema do
  let(:context) { { current_admin: admin } }
  let(:variables) { {} }
  let(:result) do
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  let(:admin) { FactoryBot.create(:admin, team: team_one) }
  let(:app1) { FactoryBot.create(:app, team: team_one, name: "App Z") }
  let(:app2) { FactoryBot.create(:app, team: team_one, name: "App A") }
  let(:email1) { FactoryBot.create(:email, app: app1) }
  let(:email2) { FactoryBot.create(:email, app: app2) }
  let(:delivery1) { FactoryBot.create(:delivery, email: email1) }
  let(:delivery2) { FactoryBot.create(:delivery, email: email2) }

  before :each do
    delivery1
    delivery2
  end

  describe "email" do
    let(:query_string) { "query($id: ID!) { email(id: $id) { id } }" }
    let(:variables) { { id: delivery1.id } }

    it "should return a valid result" do
      expect(result["data"]["email"]["id"]).to eq delivery1.id.to_s
      expect(result["errors"]).to be_nil
    end

    context "with no current user" do
      let(:context) { {} }

      it "should return nil and error" do
        expect(result["data"]["email"]).to be_nil
        expect(result["errors"].length).to eq 1
        expect(result["errors"][0]["message"]).to eq "Not authorized to access Query.email"
      end
    end

    context "with a user in a different team" do
      let(:admin) { FactoryBot.create(:admin, team: team_two) }

      it "should return nil and an error" do
        expect(result["data"]["email"]).to be_nil
        expect(result["errors"].length).to eq 1
        expect(result["errors"][0]["message"]).to eq "Not authorized to access Email.id"
      end
    end

    context "query for non existing email" do
      let(:variables) { { id: (delivery2.id + 1) } }

      it "should return nil and error" do
        expect(result["data"]["email"]).to be_nil
        expect(result["errors"].length).to eq 1
        expect(result["errors"][0]["message"]).to eq "Email doesn't exist"
      end
    end
  end

  describe "emails" do
    let(:query_string) { "query($appId: ID, $limit: Int, $offset: Int) { emails(appId: $appId, limit: $limit, offset: $offset) { totalCount nodes { id } } }" }

    it "should return emails" do
      expect(result["data"]["emails"]["nodes"]).to contain_exactly(
        { "id" => delivery1.id.to_s },
        "id" => delivery2.id.to_s
      )
      expect(result["data"]["emails"]["totalCount"]).to eq 2
      expect(result["errors"]).to be_nil
    end

    context "with no current user" do
      let(:context) { {} }

      it "should return nil and error" do
        expect(result["data"]["emails"]).to be_nil
        expect(result["errors"].length).to eq 1
        expect(result["errors"][0]["message"]).to eq "Not authorized to access Query.emails"
      end
    end

    context "with a user in a different team" do
      let(:admin) { FactoryBot.create(:admin, team: team_two) }

      it "should return no emails" do
        expect(result["data"]["emails"]["nodes"]).to be_empty
        expect(result["data"]["emails"]["totalCount"]).to eq 0
        expect(result["errors"]).to be_nil
      end
    end

    context "result for one app" do
      let(:variables) { { "appId" => app1.id } }

      it "should return just one email" do
        expect(result["data"]["emails"]["nodes"]).to contain_exactly(
          "id" => delivery1.id.to_s
        )
        expect(result["data"]["emails"]["totalCount"]).to eq 1
        expect(result["errors"]).to be_nil
      end
    end

    context "page size of 1" do
      let(:variables) { { limit: 1 } }

      it "should return just one email" do
        expect(result["data"]["emails"]["nodes"]).to contain_exactly(
          "id" => delivery2.id.to_s
        )
        expect(result["data"]["emails"]["totalCount"]).to eq 2
        expect(result["errors"]).to be_nil
      end

      context "offset of 1" do
        let(:variables) { { limit: 1, offset: 1 } }

        it "should return just one email" do
          expect(result["data"]["emails"]["nodes"]).to contain_exactly(
            "id" => delivery1.id.to_s
          )
          expect(result["data"]["emails"]["totalCount"]).to eq 2
          expect(result["errors"]).to be_nil
        end
      end
    end
  end

  describe "teams" do
    let(:query_string) { "{ teams { admins { name } apps { name } } }" }
    before(:each) do
      team_one
      team_two
    end

    it "should return null" do
      expect(result["data"]["teams"]).to be_nil
    end

    it "should return an error" do
      expect(result["errors"][0]["message"]).to eq "Not authorized to access Query.teams"
    end

    context "admin is a site admin" do
      let(:admin) do
        FactoryBot.create(:admin, team: team_one, site_admin: true, name: "Matthew")
      end

      it "should return all the teams" do
        expect(result["data"]["teams"]).to eq [
          {
            "admins" => [{ "name" => "Matthew" }],
            "apps" => [{ "name" => "App A" }, { "name" => "App Z" }]
          },
          {
            "admins" => [],
            "apps" => []
          }
        ]
      end
    end
  end
end
