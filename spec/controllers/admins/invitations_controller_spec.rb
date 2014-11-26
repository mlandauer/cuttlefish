require 'spec_helper'

describe Admins::InvitationsController do
  before :each do
    request.env["devise.mapping"] = Devise.mappings[:admin]
    request.env['HTTPS'] = 'on'
  end

  let(:team) { Team.create! }
  let(:admin) { team.admins.create!(email: "foo@bar.com", password: "guess this") }

  describe "#create" do
    context "signed in" do
      before(:each) { sign_in admin }

      it "should invite a user by their email address and make them part of the team" do
        Admin.should_receive(:invite!).with({"email" => "matthew@foo.bar", "team_id" => team.id}, admin).and_call_original
        post :create, admin: {email: "matthew@foo.bar"}
        response.should redirect_to("/dash")
      end
    end
  end
end
