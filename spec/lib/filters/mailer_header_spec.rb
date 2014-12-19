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
        Mail.new(filter.data(delivery)).header["X-Mailer"].to_s.should == "Cuttlefish 1.2"
      end

      it "shouldn't alter anything else" do
        Mail.new(filter.data(delivery)).text_part.decoded.should == 'An email with some text and headers'
      end
    end

    # context "dkim is disabled" do
    #   it { Mail.new(filter.data(delivery)).header["DKIM-Signature"].should be_nil }
    # end
    #
    # context "dkim is enabled" do
    #   before(:each) { app.update_attributes(dkim_enabled: true) }
    #
    #   context "email from dkim domain" do
    #     before(:each) { delivery.stub(from_domain: "foo.com") }
    #     it {
    #       # Signature is different every time (because of I assume a random salt). So, we're just
    #       # going to test for the presence of the header
    #       Mail.new(filter.data(delivery)).header["DKIM-Signature"].should_not be_nil
    #     }
    #   end
    #
    #   context "email from a different domain" do
    #     before(:each) { delivery.stub(from_domain: "bar.com") }
    #     it { Mail.new(filter.data(delivery)).header["DKIM-Signature"].should be_nil }
    #   end
    # end
  end
end
