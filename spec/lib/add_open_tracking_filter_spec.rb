require "spec_helper"

describe AddOpenTrackingFilter do
  let(:delivery) do
    delivery = Delivery.new(id: 673)
    delivery.stub(update_status!: nil)
    delivery.save!
    delivery
  end
  let(:filter) { AddOpenTrackingFilter.new(delivery) }

  describe "#url" do
    before :each do
      # Doing this so we don't need to set any email content (with an html part)
      delivery.set_open_tracked!
    end

    it "should normally be an https url to the default domain" do
      delivery.stub_chain(:email, :app, :open_tracking_domain).and_return(nil)
      filter.url.should == "https://cuttlefish.example.org/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif"
    end

    it "should normally be an https url to the default domain if there is no app set" do
      delivery.stub_chain(:email, :app).and_return(nil)
      filter.url.should == "https://cuttlefish.example.org/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif"
    end

    it "should use a custom domain if it is set (and also not use ssl)" do
      # This is not nice. Far too much knowledge of other classes
      # TODO Refactor
      delivery.stub_chain(:email, :app, :open_tracking_domain).and_return("email.planningalerts.org.au")
      filter.url.should == "http://email.planningalerts.org.au/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif"      
    end
  end

  describe "#data" do
    before :each do
      delivery.stub(data: mail.encoded)
      delivery.stub_chain(:email, :app, :open_tracking_domain).and_return(nil)
    end

    context "An html email with no text part" do
      let(:mail) do
        Mail.new do
          html_part do
            content_type 'text/html; charset=UTF-8'
            body '<h1>This is HTML</h1>'
          end
        end
      end

      it "should insert an image at the bottom of the html" do
        Mail.new(filter.data).parts.first.body.should ==
          '<h1>This is HTML</h1><img src="https://cuttlefish.example.org/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif" />'
      end

      it "should record that it has been open tracked" do
        filter.data
        delivery.open_tracked?.should be_true
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
        filter.data.should == mail.encoded
      end

      it "should record that it has not been open tracked" do
        filter.data
        delivery.open_tracked?.should_not be_true
      end
    end

    context "a text email with a single part" do
      let(:mail) do
        Mail.new do
          body 'Some plain text'
        end
      end

      it "should do nothing to the content of the email" do
        filter.data.should == mail.encoded
      end

      it "should record that it has not been open tracked" do
        filter.data
        delivery.open_tracked?.should_not be_true
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
          Mail.new(filter.data).text_part.decoded.should == "Some plain text"
        end

        it "should append an image to the html part of the email" do
          Mail.new(filter.data).html_part.decoded.should == "<table>I like css</table><img src=\"https://cuttlefish.example.org/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif\" />"
        end

        it "should record that it has been open tracked" do
          filter.data
          delivery.open_tracked?.should be_true
        end
    end
  end
end