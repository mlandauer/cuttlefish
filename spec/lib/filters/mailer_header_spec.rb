require "spec_helper"

describe Filters::MailerHeader do
  let(:mail) do
    Mail.new do
      text_part do
        body 'An email with some text and headers'
      end
    end
  end
  let(:app) { mock_model(App) }
  let(:delivery) { mock_model(Delivery, app: app, data: mail.encoded) }
  let(:filter) { Filters::MailerHeader.new(delivery) }

  describe "#data" do
    context "Version 1.2 of the app" do
      before :each do
        stub_const("APP_VERSION", "1.2")
      end

      it "should add an X-Mailer header" do
        filter.filter_mail(Mail.new(delivery.data)).header["X-Mailer"].to_s.should == "Cuttlefish 1.2"
      end

      it "shouldn't alter anything else" do
        filter.filter_mail(Mail.new(delivery.data)).text_part.decoded.should == 'An email with some text and headers'
      end
    end
  end
end
