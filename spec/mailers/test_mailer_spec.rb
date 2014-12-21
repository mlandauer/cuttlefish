require "spec_helper"

describe TestMailer do
  describe "#test" do
    let(:app) { mock_model(App, smtp_username: "default_1", smtp_password: "a_password") }
    let(:email) {
      TestMailer.test_email(app, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org, foo@foo.com", cc: "another@bar.com",
        subject: "Test", text: "Hello. How are you?")
    }

    it { expect(email.from).to eq ["contact@cuttlefish.io"] }
    it { expect(email.to).to eq ["matthew@openaustralia.org", "foo@foo.com"] }
    it { expect(email.cc).to eq ["another@bar.com"] }
    it { expect(email.subject).to eq "Test" }
    it { expect(email.text_part.body).to eq "Hello. How are you?" }
    it { expect(email.html_part.body.to_s).to eq "<p>Hello. How are you?</p>\n" }

    it "should be sent via the Cuttlefish server to the correct App" do
      expect(email.delivery_method.settings[:address]).to eq "localhost"
      expect(email.delivery_method.settings[:port]).to eq 2525
      expect(email.delivery_method.settings[:user_name]).to eq "default_1"
      expect(email.delivery_method.settings[:password]).to eq "a_password"
      expect(email.delivery_method.settings[:authentication]).to eq :plain
    end
  end
end
