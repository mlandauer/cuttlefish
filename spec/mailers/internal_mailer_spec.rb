require "spec_helper"

describe InternalMailer do
  describe "#invitation_instructions" do
    let(:admin1) { mock_model(Admin, display_name: "Matthew") }
    let(:admin) { mock_model(Admin, email: "foo@bar.com", invited_by: admin1) }
    let(:email) { InternalMailer.invitation_instructions(admin, "abc123") }

    it { expect(email.from).to eq ["contact@cuttlefish.oaf.org.au"] }
    it { expect(email.to).to eq ["foo@bar.com"] }
    it { expect(email.subject).to eq "Matthew invites you to Cuttlefish" }
    it do
      expect(email.body).to eq <<-EOF
<p>Matthew invites you to Cuttlefish - an easy to use transactional email server with a lovely user interface</p>

<p>Accept the invitation through the link below.</p>

<p><a href="https://localhost/admins/invitation/accept?invitation_token=abc123">Accept invitation</a></p>

<p>If you don't want to accept the invitation, please ignore this email.<br />Your account won't be created until you access the link above and set your password.</p>
      EOF
    end

    it do
      expect(email.delivery_method.settings).to eq ({
        address: "localhost",
        port: 2525,
        user_name: App.cuttlefish.smtp_username,
        password: App.cuttlefish.smtp_password,
        # So that we don't get a certificate name and host mismatch we're just
        # disabling the check.
        openssl_verify_mode: "none",
        authentication: :plain
      })
    end
  end
end
