# frozen_string_literal: true

require "spec_helper"

describe AppsHelper, type: :helper do
  describe ".email_with_name" do
    it do
      admin = Admin.new(email: "matthew@foo.com")
      expect(helper.email_with_name(admin)).to eq "matthew@foo.com"
    end

    it do
      admin = Admin.new(email: "matthew@foo.com", name: "Matthew")
      expect(helper.email_with_name(admin)).to eq "Matthew <matthew@foo.com>"
    end
  end
end
