# frozen_string_literal: true

require "spec_helper"

describe Admins::RegistrationsController, type: :controller do
  before do
    request.env["HTTPS"] = "on"
  end

  context "when this a new install of Cuttlefish with no users" do
    it "allows an admin to register" do
      get :new
      expect(response).to be_successful
    end

    it "allows an admin to register" do
      post :create
      expect(response).to be_successful
    end
  end

  context "when there is already one admin registered" do
    let(:team) { Team.create! }
    let(:admin) do
      team.admins.create!(email: "foo@bar.com", password: "guess this")
    end

    before do
      admin
    end

    it "does not allow an admin to register" do
      get :new
      expect(response).not_to be_successful
    end

    it "does not allow an admin to register" do
      post :create
      expect(response).to redirect_to(new_admin_session_url)
    end

    it "allows an admin to update their account details" do
      sign_in admin
      get :edit
      expect(response).to be_successful
    end

    it "allows an admin to update their account details" do
      sign_in admin
      post :update
      expect(response).to be_successful
    end
  end
end
