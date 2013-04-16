require "spec_helper"

describe AddOpenTrackingFilter do
  describe "#data" do
    let(:delivery) do
      delivery = Delivery.new(id: 673)
      delivery.stub(data: mail.encoded, update_status!: nil)
      delivery.save!
      delivery
    end
    let(:filter) { AddOpenTrackingFilter.new(delivery) }

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
          '<h1>This is HTML</h1><img src="http://cuttlefish.example.org/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif" />'
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
          Mail.new(filter.data).html_part.decoded.should == "<table>I like css</table><img src=\"http://cuttlefish.example.org/o/268c51c4f61875f05c1c545ea50cad826de46ea7.gif\" />"
        end

        it "should record that it has been open tracked" do
          filter.data
          delivery.open_tracked?.should be_true
        end
    end
  end
end