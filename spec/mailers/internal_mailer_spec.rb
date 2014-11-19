require "spec_helper"

describe InternalMailer do
  describe "#invitation_instructions" do
    let(:admin) { mock_model(Admin, email: "foo@bar.com") }
    let(:email) { InternalMailer.invitation_instructions(admin, "abc123") }

    it { email.from.should == ["contact@openaustraliafoundation.org.au"] }
    it { email.to.should == ["foo@bar.com"] }
    it { email.subject.should == "Invitation instructions" }
    it do
      email.body.should == <<-EOF
<p>Hello foo@bar.com!</p>

<p>Someone has invited you to https://cuttlefish.example.org/, you can accept it through the link below.</p>

<p><a href="https://cuttlefish.example.org/admins/invitation/accept?invitation_token=abc123">Accept invitation</a></p>

<p>If you don't want to accept the invitation, please ignore this email.<br />
Your account won't be created until you access the link above and set your password.</p>
      EOF
    end

    it do
      email.delivery_method.settings.should == {
        address: "localhost",
        port: 25
      }
    end
  end
end
