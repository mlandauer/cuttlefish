# coding: utf-8
require "spec_helper"

describe Filters::AddOpenTracking do
  let(:team) { Team.create! }
  let(:app) { App.create!(name: "foo", team: team) }
  let(:email) { Email.create!(app: app) }
  let(:delivery) do
    delivery = Delivery.new(id: 673, email: email)
    delivery.stub(update_status!: nil)
    delivery.save!
    delivery
  end
  let(:filter) { Filters::AddOpenTracking.new(delivery) }

  describe "#url" do
    before :each do
      # Doing this so we don't need to set any email content (with an html part)
      delivery.set_open_tracked!
    end

    it "should normally be an https url to the default domain" do
      delivery.stub_chain(:email, :custom_tracking_domain).and_return(nil)
      filter.url.should == "https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif"
    end

    it "should use a custom domain if it is set (and also not use ssl)" do
      # This is not nice. Far too much knowledge of other classes
      # TODO Refactor
      delivery.stub_chain(:email, :custom_tracking_domain).and_return("email.planningalerts.org.au")
      filter.url.should == "http://email.planningalerts.org.au/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif"
    end
  end

  describe "#data" do
    let(:email) { mock_model(Email, custom_tracking_domain: nil, open_tracking_enabled?: true) }
    before :each do
      delivery.stub(data: mail.encoded, email: email)
    end

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
        filter.filter_mail(Mail.new(delivery.data)).parts.first.decoded.should ==
          '<h1>This is HTML with “some” UTF-8</h1><img src="https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif" />'
      end

      it "should record that it has been open tracked" do
        filter.filter_mail(Mail.new(delivery.data))
        delivery.should be_open_tracked
      end

      context "app has disabled open tracking" do
        before :each do
          delivery.stub(open_tracking_enabled?: false)
        end

        it "should record that it has not been open tracked" do
          filter.filter_mail(Mail.new(delivery.data))
          delivery.should_not be_open_tracked
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
        filter.filter_mail(Mail.new(delivery.data)).to_s.should == mail.encoded
      end

      it "should record that it has not been open tracked" do
        filter.filter_mail(Mail.new(delivery.data))
        delivery.open_tracked?.should_not be_truthy
      end
    end

    context "a text email with a single part" do
      let(:mail) do
        Mail.new do
          body 'Some plain text'
        end
      end

      it "should do nothing to the content of the email" do
        filter.filter_mail(Mail.new(delivery.data)).to_s.should == mail.encoded
      end

      it "should record that it has not been open tracked" do
        filter.filter_mail(Mail.new(delivery.data))
        delivery.open_tracked?.should_not be_truthy
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
        filter.filter_mail(Mail.new(delivery.data)).body.should == "<p>Hello This an html email</p>\n<img src=\"https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif\" />"
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
          filter.filter_mail(Mail.new(delivery.data)).text_part.decoded.should == "Some plain text"
        end

        it "should append an image to the html part of the email" do
          filter.filter_mail(Mail.new(delivery.data)).html_part.decoded.should == "<table>I like css</table><img src=\"https://localhost/o/673/7160aac874571221e97d4bad21a63b2a12f907d8.gif\" />"
        end

        it "should record that it has been open tracked" do
          filter.filter_mail(Mail.new(delivery.data))
          delivery.open_tracked?.should be_truthy
        end
    end
  end
end
