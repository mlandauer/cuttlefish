require 'spec_helper'

describe Settings do
  describe ".smtp_all_authenticated" do
    it "should have a default value of false" do
      Settings.smtp_all_authenticated.should == false
    end

    it "can be set" do
      Settings.smtp_all_authenticated = true
      Settings.smtp_all_authenticated.should == true
      Settings.destroy :smtp_all_authenticated
    end
  end
end