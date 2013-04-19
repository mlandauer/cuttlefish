require 'spec_helper'

describe EmailsController do
  context "signed in" do
    before :each do
      admin = Admin.create!(:email => "foo@bar.com", :password => "guess this")
      sign_in admin
    end

    describe "GET index" do
      it "assigns all emails as @emails" do
        email = Email.create!
        get :index, {}
        assigns(:emails).should eq([email])
      end
    end

    describe "GET show" do
      it "assigns the requested email as @email" do
        email = Email.create!
        get :show, {:id => email.to_param}
        assigns(:email).should eq(email)
      end
    end
  end
end
