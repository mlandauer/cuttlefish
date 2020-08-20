# frozen_string_literal: true

require "spec_helper"

describe EmailServices::ParseHeadersCreate do
  let(:app) { create(:app) }
  let(:service) { EmailServices::ParseHeadersCreate.new(to: "bar@bar.com", data: data, app_id: app.id) }

  context "An email with no special headers" do
    let(:data) do
      [
        "Date: Fri, 13 Mar 2015 14:42:20 +0000",
        "From: Foo <foo@foo.com>",
        "To: bar@bar.com",
        "Message-ID: <1234@foo>",
        "Subject: Yes",
        "Mime-Version: 1.0",
        "Content-Type: text/plain;",
        " charset=utf-8",
        "Content-Transfer-Encoding: quoted-printable",
        "",
        "Hello=\n"
      ].join("\r\n")
    end

    it "should return the defaults for the options" do
      _, options = service.parse_and_remove_special_headers
      expect(options).to eq(ignore_deny_list: false, meta_values: {})
    end

    it "should not change the headers" do
      new_data, = service.parse_and_remove_special_headers
      expect(new_data).to eq data
    end
  end

  context "An email with custom metadata headers" do
    let(:data) do
      [
        "Date: Fri, 13 Mar 2015 14:42:20 +0000",
        "From: Foo <foo@foo.com>",
        "To: bar@bar.com",
        "X-Cuttlefish-Metadata-foo_foo: bar",
        "X-Cuttlefish-Metadata-goo-goo: bar",
        "X-Cuttlefish-Metadata-wibble: wobble",
        "Message-ID: <1234@foo>",
        "Subject: Yes",
        "Mime-Version: 1.0",
        "Content-Type: text/plain;",
        " charset=utf-8",
        "Content-Transfer-Encoding: quoted-printable",
        "",
        "Hello=\n"
      ].join("\r\n")
    end

    it "should return the metadata values" do
      _, options = service.parse_and_remove_special_headers
      # Make sure that underscores and dashes are preserved correctly
      expect(options[:meta_values]).to eq("foo_foo" => "bar", "goo-goo" => "bar", "wibble" => "wobble")
    end

    it "should remove the the headers" do
      new_data, = service.parse_and_remove_special_headers
      expect(new_data).to eq [
        "Date: Fri, 13 Mar 2015 14:42:20 +0000",
        "From: Foo <foo@foo.com>",
        "To: bar@bar.com",
        "Message-ID: <1234@foo>",
        "Subject: Yes",
        "Mime-Version: 1.0",
        "Content-Type: text/plain;",
        " charset=utf-8",
        "Content-Transfer-Encoding: quoted-printable",
        "",
        "Hello=\n"
      ].join("\r\n")
    end
  end

  context "An email with the ignore deny list header" do
    let(:data) do
      [
        "Date: Fri, 13 Mar 2015 14:42:20 +0000",
        "From: Foo <foo@foo.com>",
        "To: bar@bar.com",
        "Message-ID: <1234@foo>",
        "Subject: Yes",
        "X-Cuttlefish-Ignore-Deny-List: true",
        "Mime-Version: 1.0",
        "Content-Type: text/plain;",
        " charset=utf-8",
        "Content-Transfer-Encoding: quoted-printable",
        "",
        "Hello=\n"
      ].join("\r\n")
    end

    it "should have the setting set" do
      _, options = service.parse_and_remove_special_headers
      expect(options[:ignore_deny_list]).to be true
    end

    it "should remove the the header" do
      new_data, = service.parse_and_remove_special_headers
      expect(new_data).to eq [
        "Date: Fri, 13 Mar 2015 14:42:20 +0000",
        "From: Foo <foo@foo.com>",
        "To: bar@bar.com",
        "Message-ID: <1234@foo>",
        "Subject: Yes",
        "Mime-Version: 1.0",
        "Content-Type: text/plain;",
        " charset=utf-8",
        "Content-Transfer-Encoding: quoted-printable",
        "",
        "Hello=\n"
      ].join("\r\n")
    end
  end
end
