# frozen_string_literal: true

require "spec_helper"

describe Admins::SessionsController, type: :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:admin]
  end

  context "when request is over http" do
    context "when there is one admin already registered" do
      before do
        team = Team.create!
        team.admins.create!(email: "foo@bar.com", password: "guess this")
      end

      it "redirects to https" do
        get :new
        expect(response).to redirect_to(action: :new, protocol: "https")
      end
    end
  end

  context "when request is over https" do
    before do
      request.env["HTTPS"] = "on"
    end

    context "when this is a fresh install and there are no admins registered" do
      it "redirects to the registration page" do
        get :new
        expect(response).to redirect_to new_admin_registration_url
      end
    end

    context "when there is one admin already registered" do
      before do
        team = Team.create!
        team.admins.create!(email: "foo@bar.com", password: "guess this")
      end

      it "does not redirect https" do
        get :new
        expect(response).to be_successful
      end
    end
  end
end
