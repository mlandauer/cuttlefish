require 'spec_helper'

describe App do
  describe "#smtp_password" do
    it "should create a password consisting of two words" do
      app = App.create!
      app.smtp_password.split(" ").count.should == 2
    end

    it "should create a password that is different every time" do
      app1 = App.create!
      app2 = App.create!
      app1.smtp_password.should_not == app2.smtp_password
    end
  end
end
