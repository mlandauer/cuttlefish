# frozen_string_literal: true

require "spec_helper"

describe Admin do
  describe ".email_with_name" do
    it do
      admin = Admin.new(email: "matthew@foo.com")
      expect(admin.email_with_name).to eq "matthew@foo.com"
    end

    it do
      admin = Admin.new(email: "matthew@foo.com", name: "Matthew")
      expect(admin.email_with_name).to eq "Matthew <matthew@foo.com>"
    end
  end
end
