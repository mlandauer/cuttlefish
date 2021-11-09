# frozen_string_literal: true

require "spec_helper"

describe Filters::AddOpenTracking do
  let(:tracking_domain_info) { { protocol: "https", domain: "localhost" } }
  let(:filter) do
    described_class.new(
      delivery_id: 673,
      enabled: true,
      tracking_domain_info: tracking_domain_info
    )
  end

  describe "#url" do
    it "is normally an https url to the default domain" do
      expect(filter.url).to eq "https://localhost/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif"
    end

    context "using a different domain over http" do
      let(:tracking_domain_info) do
        { protocol: "http", domain: "email.planningalerts.org.au" }
      end

      it "uses a custom domain if it is set (and also not use ssl)" do
        expect(filter.url).to eq "http://email.planningalerts.org.au/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif"
      end
    end
  end

  describe "#data" do
    context "An html email with no text part" do
      let(:mail) do
        Mail.new do
          html_part do
            content_type "text/html; charset=UTF-8"
            body "<h1>This is HTML with “some” UTF-8</h1>"
          end
        end
      end

      it "inserts an image at the bottom of the html" do
        hash = "05c6b2136e9c1297c0264427a17aa3cf4ea40b3e"
        expect(filter.filter_mail(mail).parts.first.decoded).to eq(
          "<h1>This is HTML with “some” UTF-8</h1>" \
          "<img src=\"https://localhost/o2/673/#{hash}.gif\" />"
        )
      end

      context "app has disabled open tracking" do
        before do
          filter.enabled = false
        end
      end
    end

    context "a text email with no html part" do
      let(:mail) do
        Mail.new do
          text_part do
            body "Some plain text"
          end
        end
      end

      it "does nothing to the content of the email" do
        expect(filter.filter_mail(mail).to_s).to eq mail.encoded
      end
    end

    context "a text email with a single part" do
      let(:mail) do
        Mail.new do
          body "Some plain text"
        end
      end

      it "does nothing to the content of the email" do
        expect(filter.filter_mail(mail).to_s).to eq mail.encoded
      end
    end

    context "an html email with one part" do
      let(:body) do
        <<~EMAIL
          From: They Vote For You <contact@theyvoteforyou.org.au>
          To: matthew@openaustralia.org
          Subject: An html email
          Mime-Version: 1.0
          Content-Type: text/html;
           charset=UTF-8
          Content-Transfer-Encoding: 7bit

          <p>Hello This an html email</p>
        EMAIL
      end

      let(:mail) do
        Mail.new(body)
      end

      it "adds an image" do
        hash = "05c6b2136e9c1297c0264427a17aa3cf4ea40b3e"
        expect(filter.filter_mail(mail).body).to eq(
          "<p>Hello This an html email</p>\n" \
          "<img src=\"https://localhost/o2/673/#{hash}.gif\" />"
        )
      end
    end

    context "an email with a text part and an html part" do
      let(:mail) do
        Mail.new do
          text_part do
            body "Some plain text"
          end
          html_part do
            content_type "text/html; charset=UTF-8"
            body "<table>I like css</table>"
          end
        end
      end

      it "does nothing to the text part of the email" do
        expect(filter.filter_mail(mail).text_part.decoded).to eq(
          "Some plain text"
        )
      end

      it "appends an image to the html part of the email" do
        hash = "05c6b2136e9c1297c0264427a17aa3cf4ea40b3e"
        expect(filter.filter_mail(mail).html_part.decoded).to eq(
          "<table>I like css</table>" \
          "<img src=\"https://localhost/o2/673/#{hash}.gif\" />"
        )
      end
    end
  end
end
