require 'spec_helper'

describe Admins::SessionsController do
  before :each do
    request.env["devise.mapping"] = Devise.mappings[:admin]
  end

  context "There is one admin already registered" do
    before :each do
      Admin.create!(:email => "foo@bar.com", :password => "guess this")
    end

    it "should redirect to https" do
      get :new
      response.should redirect_to(:action => :new, :protocol => "https")
    end

    it "should not redirect https" do
      request.env['HTTPS'] = 'on'
      get :new
      response.should be_success
    end
  end
end

