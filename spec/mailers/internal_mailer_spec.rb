require "spec_helper"

describe InternalMailer do
  describe "#invitation_instructions" do
    let(:admin1) { mock_model(Admin, display_name: "Matthew") }
    let(:admin) { mock_model(Admin, email: "foo@bar.com", invited_by: admin1) }
    let(:email) { InternalMailer.invitation_instructions(admin, "abc123") }

    it { email.from.should == ["contact@openaustraliafoundation.org.au"] }
    it { email.to.should == ["foo@bar.com"] }
    it { email.subject.should == "Matthew invites you to Cuttlefish" }
    it do
      email.body.should == <<-EOF
<p>Matthew invites you to Cuttlefish - an easy to use transactional email server with a lovely user interface</p>

<p>Accept the invitation through the link below.</p>

<p><a href="https://cuttlefish.example.org/admins/invitation/accept?invitation_token=abc123">Accept invitation</a></p>

<p>If you don't want to accept the invitation, please ignore this email.<br />Your account won't be created until you access the link above and set your password.</p>
      EOF
    end

    it do
      email.delivery_method.settings.should == {
        address: "localhost",
        port: 25,
        enable_starttls_auto: false
      }
    end
  end
end
