# coding: utf-8
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
      filter.url.should == "https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif"
    end

    it "should use a custom domain if it is set (and also not use ssl)" do
      # This is not nice. Far too much knowledge of other classes
      # TODO Refactor
      filter.tracking_domain = "email.planningalerts.org.au"
      filter.using_custom_tracking_domain = true
      filter.url.should == "http://email.planningalerts.org.au/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif"
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
        filter.filter_mail(mail).parts.first.decoded.should ==
          '<h1>This is HTML with “some” UTF-8</h1><img src="https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif" />'
      end

      it "should record that it has been open tracked" do
        delivery.should_receive(:set_open_tracked!)
        filter.filter_mail(mail)
      end

      context "app has disabled open tracking" do
        before :each do
          filter.enabled = false
        end

        it "should record that it has not been open tracked" do
          delivery.should_not_receive(:set_open_tracked!)
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
        filter.filter_mail(mail).to_s.should == mail.encoded
      end

      it "should record that it has not been open tracked" do
        delivery.should_not_receive(:set_open_tracked!)
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
        filter.filter_mail(mail).to_s.should == mail.encoded
      end

      it "should record that it has not been open tracked" do
        delivery.should_not_receive(:set_open_tracked!)
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
        filter.filter_mail(mail).body.should == "<p>Hello This an html email</p>\n<img src=\"https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif\" />"
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
          filter.filter_mail(mail).text_part.decoded.should == "Some plain text"
        end

        it "should append an image to the html part of the email" do
          filter.filter_mail(mail).html_part.decoded.should == "<table>I like css</table><img src=\"https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif\" />"
        end

        it "should record that it has been open tracked" do
          delivery.should_receive(:set_open_tracked!)
          filter.filter_mail(mail)
        end
    end
  end
end
