require 'spec_helper'

describe Admins::RegistrationsController do
  before :each do
    request.env["devise.mapping"] = Devise.mappings[:admin]
    request.env['HTTPS'] = 'on'
  end

  context "This a new install of Cuttlefish with no users" do
    it "should allow an admin to register" do
      get :new
      response.should be_success
    end

    it "should allow an admin to register" do
      post :create
      response.should be_success
    end
  end

  context "There is already one admin registered" do
    let(:admin) { Admin.create!(email: "foo@bar.com", password: "guess this") }
    before :each do
      admin
    end

    it "should not allow an admin to register" do
      get :new
      response.should_not be_success
    end

    it "should not allow an admin to register" do
      post :create
      response.should_not be_success
    end

    it "should allow an admin to update their account details" do
      sign_in admin
      get :edit
      response.should be_success
    end

    it "should allow an admin to update their account details" do
      sign_in admin
      post :update
      response.should be_success
    end
  end
end

