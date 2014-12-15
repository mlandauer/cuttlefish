require 'spec_helper'

describe Admin do
  describe ".email_with_name" do
    it do
      admin = Admin.new(email: "matthew@foo.com")
      admin.email_with_name.should == "matthew@foo.com"
    end

    it do
      admin = Admin.new(email: "matthew@foo.com", name: "Matthew")
      admin.email_with_name.should == "Matthew <matthew@foo.com>"
    end
  end
end
