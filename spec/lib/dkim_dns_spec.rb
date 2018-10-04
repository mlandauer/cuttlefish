# frozen_string_literal: true

require "spec_helper"

describe DkimDns do
  let(:dkim_dns) do
    DkimDns.new(
      private_key: OpenSSL::PKey::RSA.new(2048),
      domain: "foo.com",
      selector: "cuttlefish"
    )
  end

  describe "#dkim_dns_value" do
    it "should give me the dns record value" do
      # Test certain invariants
      expect(dkim_dns.dkim_dns_value[0..8]).to eq "k=rsa; p="
      expect(dkim_dns.dkim_dns_value.count('"')).to eq 0
      expect(dkim_dns.dkim_dns_value.length).to eq 401
    end
  end

  describe "#dkim_domain" do
    it "should return the fully qualified domain name" do
      expect(dkim_dns.dkim_domain).to eq "cuttlefish._domainkey.foo.com"
    end
  end
end
