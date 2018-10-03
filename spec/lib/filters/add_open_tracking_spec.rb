# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe Filters::AddOpenTracking do
  let(:delivery) { double(Delivery, :set_open_tracked! => true) }
  let(:filter) {
    Filters::AddOpenTracking.new(
      delivery: delivery,
      delivery_id: 673,
      enabled: true,
      tracking_domain: "localhost",
      using_custom_tracking_domain: false
    )
  }

  describe "#url" do
    it "should normally be an https url to the default domain" do
      expect(filter.url).to eq "https://localhost/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif"
    end

    it "should use a custom domain if it is set (and also not use ssl)" do
      # This is not nice. Far too much knowledge of other classes
      # TODO Refactor
      filter.tracking_domain = "email.planningalerts.org.au"
      filter.using_custom_tracking_domain = true
      expect(filter.url).to eq "http://email.planningalerts.org.au/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif"
    end
  end

  describe "#data" do
    context "An html email with no text part" do
      let(:mail) do
        Mail.new do
          html_part do
            content_type 'text/html; charset=UTF-8'
            body '<h1>This is HTML with “some” UTF-8</h1>'
          end
        end
      end

      it "should insert an image at the bottom of the html" do
        expect(filter.filter_mail(mail).parts.first.decoded).to eq '<h1>This is HTML with “some” UTF-8</h1><img src="https://localhost/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif" />'
      end

      it "should record that it has been open tracked" do
        expect(delivery).to receive(:set_open_tracked!)
        filter.filter_mail(mail)
      end

      context "app has disabled open tracking" do
        before :each do
          filter.enabled = false
        end

        it "should record that it has not been open tracked" do
          expect(delivery).to_not receive(:set_open_tracked!)
          filter.filter_mail(mail)
        end
      end
    end

    context "a text email with no html part" do
      let(:mail) do
        Mail.new do
          text_part do
            body 'Some plain text'
          end
        end
      end

      it "should do nothing to the content of the email" do
        expect(filter.filter_mail(mail).to_s).to eq mail.encoded
      end

      it "should record that it has not been open tracked" do
        expect(delivery).to_not receive(:set_open_tracked!)
        filter.filter_mail(mail)
      end
    end

    context "a text email with a single part" do
      let(:mail) do
        Mail.new do
          body 'Some plain text'
        end
      end

      it "should do nothing to the content of the email" do
        expect(filter.filter_mail(mail).to_s).to eq mail.encoded
      end

      it "should record that it has not been open tracked" do
        expect(delivery).to_not receive(:set_open_tracked!)
        filter.filter_mail(mail)
      end
    end

    context "an html email with one part" do
      let(:body) do
        <<-EOF
From: They Vote For You <contact@theyvoteforyou.org.au>
To: matthew@openaustralia.org
Subject: An html email
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8
Content-Transfer-Encoding: 7bit

<p>Hello This an html email</p>
        EOF
      end

      let(:mail) do
        Mail.new(body)
      end

      it "should add an image" do
        expect(filter.filter_mail(mail).body).to eq "<p>Hello This an html email</p>\n<img src=\"https://localhost/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif\" />"
      end
    end

    context "an email with a text part and an html part" do
        let(:mail) do
          Mail.new do
            text_part do
              body 'Some plain text'
            end
            html_part do
              content_type 'text/html; charset=UTF-8'
              body '<table>I like css</table>'
            end
          end
        end

        it "should do nothing to the text part of the email" do
          expect(filter.filter_mail(mail).text_part.decoded).to eq "Some plain text"
        end

        it "should append an image to the html part of the email" do
          expect(filter.filter_mail(mail).html_part.decoded).to eq "<table>I like css</table><img src=\"https://localhost/o2/673/05c6b2136e9c1297c0264427a17aa3cf4ea40b3e.gif\" />"
        end

        it "should record that it has been open tracked" do
          expect(delivery).to receive(:set_open_tracked!)
          filter.filter_mail(mail)
        end
    end
  end
end
