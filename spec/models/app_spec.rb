require 'spec_helper'

describe App do
  describe "#smtp_password" do
    it "should create a password consisting of two words" do
      app = App.create!(name: "foo", description: "Foo")
      app.smtp_password.split(" ").count.should == 2
    end

    it "should create a password that is different every time" do
      app1 = App.create!(name: "foo", description: "Foo")
      app2 = App.create!(name: "bar", description: "Bar")
      app1.smtp_password.should_not == app2.smtp_password
    end
  end

  describe "#name" do
    let(:app) { App.new(name: "foo", description: "Foo") }

    it "should have a lower case name" do
      app.name = "abcdef"
      app.should be_valid
    end

    it "should not allow upper case letters" do
      app.name = "abcDef"
      app.should_not be_valid
    end

    it "should allow underscores and numbers too" do
      app.name = "abcd_123_bf"
      app.should be_valid
    end

    it "but not spaces" do
      app.name = "abcd 123_bf"
      app.should_not be_valid
    end

    context "An app with the name foo exists" do
      before :each do
        app.save!
      end

      it "should not allow a second app with the same name" do
        App.new(name: "foo", description: "Foo").should_not be_valid
      end
    end
  end
end
