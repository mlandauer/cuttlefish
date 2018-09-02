require 'spec_helper'

describe Admins::SessionsController, type: :controller do
  before :each do
    request.env["devise.mapping"] = Devise.mappings[:admin]
  end

  context "request is over http" do
    context "There is one admin already registered" do
      before :each do
        team = Team.create!
        team.admins.create!(email: "foo@bar.com", password: "guess this")
      end

      it "should redirect to https" do
        get :new
        expect(response).to redirect_to(action: :new, protocol: "https")
      end
    end
  end

  context "request is over https" do
    before :each do
      request.env['HTTPS'] = 'on'
    end

    context "This is a fresh install of Cuttlefish and there are no admins registered" do
      it "should redirect to the registration page" do
        get :new
        expect(response).to redirect_to new_admin_registration_url
      end
    end

    context "There is one admin already registered" do
      before :each do
        team = Team.create!
        team.admins.create!(email: "foo@bar.com", password: "guess this")
      end

      it "should not redirect https" do
        get :new
        expect(response).to be_successful
      end
    end
  end
end
