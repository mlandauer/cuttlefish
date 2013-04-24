require 'spec_helper'

describe App do
  describe "#smtp_password" do
    it "should create a password consisting of two words" do
      app = App.create!(name: "foo")
      app.smtp_password.split(" ").count.should == 2
    end

    it "should create a password that is different every time" do
      app1 = App.create!(name: "foo")
      app2 = App.create!(name: "bar")
      app1.smtp_password.should_not == app2.smtp_password
    end
  end

  describe "#name" do
    it "should have a lower case name" do
      App.new(name: "abcdef").should be_valid
    end

    it "should not allow upper case letters" do
      App.new(name: "abcDef").should_not be_valid
    end

    it "should allow underscores and numbers too" do
      App.new(name: "abcd_123_bf").should be_valid
    end

    it "but not spaces" do
      App.new(name: "abcd 123_bf").should_not be_valid
    end

    context "An app with the name foo exists" do
      before :each do
        App.create!(name: "foo")
      end

      it "should not allow a second app with the same name" do
        App.new(name: "foo").should_not be_valid
      end
    end
  end
end
