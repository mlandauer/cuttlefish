require 'spec_helper'

describe App do
  describe "#smtp_password" do
    it "should create a password consisting of only letter and underscores" do
      app = App.create!(description: "Foo")
      app.smtp_password.should match /^[a-z_]+$/
    end

    it "should create a password that is different every time" do
      app1 = App.create!(description: "Foo")
      app2 = App.create!(description: "Bar")
      app1.smtp_password.should_not == app2.smtp_password
    end
  end

  describe "#description" do
    it "should allow upper and lower case letters, numbers, spaces and underscores" do
      App.new(description: "Foo12 Bar_Foo").should be_valid
    end

    it "should not allow other characters" do
      App.new(description: "*").should_not be_valid
    end
  end

  describe "#name" do
    it "should set the name based on the description when created" do
      app = App.create!(name: "foo", description: "Planning Alerts", id: 15)
      app.name.should == "planning_alerts_15"
    end

    it "should not change the name if the description is updated" do
      app = App.create!(name: "foo", description: "Planning Alerts", id: 15)
      app.update_attributes(description: "Another description")
      app.name.should == "planning_alerts_15"
    end
  end
end
