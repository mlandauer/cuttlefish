require "spec_helper"

describe TestMailer do
  describe "#test" do
    let(:app) { mock_model(App, smtp_username: "default_1", smtp_password: "a_password") }
    let(:email) {
      TestMailer.test_email(app, from: "contact@cuttlefish.io", to: "matthew@openaustralia.org, foo@foo.com", cc: "another@bar.com",
        subject: "Test", text: "Hello. How are you?")
    }

    it { email.from.should == ["contact@cuttlefish.io"] }
    it { email.to.should == ["matthew@openaustralia.org", "foo@foo.com"] }
    it { email.cc.should == ["another@bar.com"] }
    it { email.subject.should == "Test" }
    it { email.text_part.body.should == "Hello. How are you?" }
    it { email.html_part.body.to_s.should == "<p>Hello. How are you?</p>\n" }

    it "should be sent via the Cuttlefish server to the correct App" do
      email.delivery_method.settings[:address].should == "localhost"
      email.delivery_method.settings[:port].should == 2525
      email.delivery_method.settings[:user_name].should == "default_1"
      email.delivery_method.settings[:password].should == "a_password"
      email.delivery_method.settings[:authentication].should == :plain
    end
  end
end
