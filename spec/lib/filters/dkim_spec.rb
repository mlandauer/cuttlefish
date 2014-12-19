require "spec_helper"

# TODO This test currently depends on the real behaviour of the App class. Fix this
describe Filters::Dkim do
  let(:mail) do
    Mail.new do
      text_part do
        body 'An email with some text and headers'
      end
    end
  end
  let(:app) { App.create(from_domain: "foo.com") }
  let(:delivery) { mock_model(Delivery, app: app, data: mail.encoded) }
  let(:filter) { Filters::Dkim.new(delivery) }

  describe "#data" do
    context "dkim is disabled" do
      it { Mail.new(filter.filter(delivery.data)).header["DKIM-Signature"].should be_nil }
    end

    context "dkim is enabled" do
      before(:each) { app.update_attributes(dkim_enabled: true) }

      context "email from dkim domain" do
        before(:each) { delivery.stub(from_domain: "foo.com") }
        it {
          # Signature is different every time (because of I assume a random salt). So, we're just
          # going to test for the presence of the header
          Mail.new(filter.filter(delivery.data)).header["DKIM-Signature"].should_not be_nil
        }
      end

      context "email from a different domain" do
        before(:each) { delivery.stub(from_domain: "bar.com") }
        it { Mail.new(filter.filter(delivery.data)).header["DKIM-Signature"].should be_nil }
      end
    end
  end
end
