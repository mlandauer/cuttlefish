require 'spec_helper'

describe App do
  describe "#smtp_password" do
    it "should create a password that is twenty characters long" do
      app = App.create!(name: "Foo")
      app.smtp_password.size.should == 20
    end

    it "should create a password that is different every time" do
      app1 = App.create!(name: "Foo")
      app2 = App.create!(name: "Bar")
      app1.smtp_password.should_not == app2.smtp_password
    end
  end

  describe "#name" do
    it "should allow upper and lower case letters, numbers, spaces and underscores" do
      App.new(name: "Foo12 Bar_Foo").should be_valid
    end

    it "should not allow other characters" do
      App.new(name: "*").should_not be_valid
    end
  end

  describe "#smtp_username" do
    it "should set the smtp_username based on the name when created" do
      app = App.create!(name: "Planning Alerts", id: 15)
      app.smtp_username.should == "planning_alerts_15"
    end

    it "should not change the smtp_username if the name is updated" do
      app = App.create!(name: "Planning Alerts", id: 15)
      app.update_attributes(name: "Another description")
      app.smtp_username.should == "planning_alerts_15"
    end
  end

  describe ".cuttlefish" do
    it { App.cuttlefish.name.should == "Cuttlefish" }
    it { App.cuttlefish.url.should == "http://cuttlefish.io" }

    it "should only create one instance even if it's called several times" do
      App.cuttlefish
      App.cuttlefish
      App.count.should == 1
    end

    it "should create a new instance even if someone has already created one called Cuttlefish" do
      App.create!(name: "Cuttlefish")
      App.cuttlefish
      App.count.should == 2
    end
  end
end
