require "spec_helper"

describe AddOpenTrackingFilter do
  # TODO Record whether image was inserted

  describe "#data" do
    context "An html email with no text part" do
      let(:mail) do
        Mail.new do
          html_part do
            content_type 'text/html; charset=UTF-8'
            body '<h1>This is HTML</h1>'
          end
        end
      end
      let(:filter) { AddOpenTrackingFilter.new(mock(:data => mail.encoded, :id => "673")) }

      # TODO Use a hash to generate the id in the image so that it can't be guessed
      it "should insert an image at the bottom of the html" do
        Mail.new(filter.data).parts.first.body.should ==
          '<h1>This is HTML</h1><img src="http://cuttlefish.example.org/o673.gif" />'
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
      let(:filter) { AddOpenTrackingFilter.new(mock(:data => mail.encoded, :id => "673")) }

      it "should do nothing to the content of the email" do
        filter.data.should == mail.encoded
      end
    end

    context "a text email with a single part" do
      let(:mail) do
        Mail.new do
          body 'Some plain text'
        end
      end
      let(:filter) { AddOpenTrackingFilter.new(mock(:data => mail.encoded, :id => "673")) }

      it "should do nothing to the content of the email" do
        filter.data.should == mail.encoded
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
        let(:filter) { AddOpenTrackingFilter.new(mock(:data => mail.encoded, :id => "12")) }

        it "should do nothing to the text part of the email" do
          Mail.new(filter.data).text_part.decoded.should == "Some plain text"
        end

        it "should append an image to the html part of the email" do
          Mail.new(filter.data).html_part.decoded.should == "<table>I like css</table><img src=\"http://cuttlefish.example.org/o12.gif\" />"
        end
    end
  end
end