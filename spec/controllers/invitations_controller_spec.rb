# frozen_string_literal: true

require "spec_helper"

describe InvitationsController, type: :controller do
  before :each do
    request.env["HTTPS"] = "on"
  end

  let(:team) { Team.create! }
  let(:admin) do
    team.admins.create!(email: "foo@bar.com", password: "guess this")
  end

  describe "#create" do
    context "signed in" do
      before(:each) { sign_in admin }

      it "invites a user by their email and make them part of the team" do
        expect(Admin).to receive(:invite!).with(
          { email: "matthew@foo.bar", team_id: team.id },
          admin,
          accept_url: "https://test.host/admins/invitation/accept"
        ).and_call_original
        post :create, params: { admin: { email: "matthew@foo.bar" } }
        expect(response).to redirect_to admins_url
      end
    end
  end
end
