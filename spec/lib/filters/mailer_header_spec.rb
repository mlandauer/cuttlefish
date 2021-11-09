# frozen_string_literal: true

require "spec_helper"

describe Filters::MailerHeader do
  let(:mail) do
    Mail.new do
      text_part do
        body "An email with some text and headers"
      end
    end
  end
  let(:filter) { Filters::MailerHeader.new(version: APP_VERSION) }

  describe "#data" do
    context "Version 1.2 of the app" do
      before(:each) { filter.version = "1.2" }

      it "adds an X-Mailer header" do
        expect(filter.filter_mail(mail).header["X-Mailer"].to_s).to eq(
          "Cuttlefish 1.2"
        )
      end

      it "does not alter anything else" do
        expect(filter.filter_mail(mail).text_part.decoded).to eq(
          "An email with some text and headers"
        )
      end
    end
  end
end
