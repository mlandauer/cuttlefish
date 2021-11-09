# frozen_string_literal: true

require "spec_helper"

describe Filters::Dkim do
  let(:mail) do
    Mail.new do
      from "Contact <contact@foo.com>"
      text_part do
        body "An email with some text and headers\nYes"
      end
      html_part do
        # Using this encoding to expose the problem of the body being
        # changed by the dkim signing process
        content_transfer_encoding "quoted-printable"
        body "<p>Hello</p>\n<p>Yes</p>"
      end
    end
  end
  let(:filter) do
    Filters::Dkim.new(
      enabled: false,
      dkim_dns: DkimDns.new(
        domain: "foo.com",
        private_key: OpenSSL::PKey::RSA.new(2048),
        selector: "cuttlefish"
      ),
      cuttlefish_enabled: false,
      cuttlefish_dkim_dns: DkimDns.new(
        domain: "cuttlefish.oaf.org.au",
        private_key: OpenSSL::PKey::RSA.new(2048),
        selector: "cuttlefish"
      ),
      sender_email: "sender@cuttlefish.oaf.org.au"
    )
  end
  let(:filter_mail) { filter.filter_mail(mail) }

  describe "#data" do
    context "dkim is disabled" do
      context "cuttlefish dkim is disabled" do
        it { expect(filter_mail.header["DKIM-Signature"]).to be_nil }
        it { expect(filter_mail.sender).to eq "sender@cuttlefish.oaf.org.au" }
      end

      context "cuttlefish dkim is enabled" do
        before { filter.cuttlefish_enabled = true }

        # This should in practise always be the case (because the domain of
        # the sender email should be the same as the cuttlefish domain)
        context "sender email is in cuttlefish domain" do
          it { expect(filter_mail.header["DKIM-Signature"]).not_to be_nil }
          it { expect(filter_mail.sender).to eq "sender@cuttlefish.oaf.org.au" }
        end

        # Note that this shouldn't happen in practise (see above)
        context "sender email is not in the cuttlefish domain" do
          before { filter.cuttlefish_dkim_dns.domain = "oaf.org.au" }

          it { expect(filter_mail.header["DKIM-Signature"]).to be_nil }
          it { expect(filter_mail.sender).to eq "sender@cuttlefish.oaf.org.au" }
        end
      end
    end

    context "dkim is enabled" do
      before { filter.enabled = true }

      context "email from dkim domain" do
        it {
          # Signature is different every time (because of I assume a random
          # salt). So, we're just going to test for the presence of the header
          expect(filter_mail.header["DKIM-Signature"]).not_to be_nil
        }

        it "does not alter the body of the email in any way" do
          # The dkim signing library puts a different line ending on the
          # body of the email than the Mail gem does. When Mail reparses
          # it ends up changing the body. Not quite sure who is right here
          # but what I do know is that the body of the email should be
          # identical before and after the filter is applied
          expect(filter_mail.text_part.body.to_s).to eq mail.text_part.body.to_s
          expect(filter_mail.html_part.body.to_s).to eq mail.html_part.body.to_s
        end

        it { expect(filter_mail.sender).to be_nil }
      end

      context "email from a different domain" do
        before { mail.from = "Contact <contact@bar.com>" }

        it { expect(filter_mail.header["DKIM-Signature"]).to be_nil }
        it { expect(filter_mail.sender).to eq "sender@cuttlefish.oaf.org.au" }

        context "and sender is in correct domain" do
          before { mail.sender = "Contact <contact@foo.com>" }

          it { expect(filter_mail.header["DKIM-Signature"]).not_to be_nil }
          it { expect(filter_mail.sender).to eq "contact@foo.com" }
        end

        context "and sender is in wrong domain" do
          before { mail.sender = "Contact <contact@bibble.com>" }

          it { expect(filter_mail.header["DKIM-Signature"]).to be_nil }
          it { expect(filter_mail.sender).to eq "sender@cuttlefish.oaf.org.au" }
        end
      end
    end
  end
end
