# frozen_string_literal: true

require "spec_helper"

describe InternalMailer do
  describe "#invitation_instructions" do
    let(:admin1) { mock_model(Admin, display_name: "Matthew") }
    let(:admin) { mock_model(Admin, email: "foo@bar.com", invited_by: admin1) }
    let(:email) { described_class.invitation_instructions(admin, "abc123", accept_url: "https://foo.com/bar") }

    it { expect(email.from).to eq ["contact@cuttlefish.oaf.org.au"] }
    it { expect(email.to).to eq ["foo@bar.com"] }
    it { expect(email.subject).to eq "Matthew invites you to Cuttlefish" }

    it do
      expect(email.body.to_s).to eq <<~HTML
        <p>Matthew invites you to Cuttlefish - an easy to use transactional email server with a lovely user interface</p>

        <p>Accept the invitation through the link below.</p>

        <p><a href="https://foo.com/bar?invitation_token=abc123">Accept invitation</a></p>

        <p>If you don't want to accept the invitation, please ignore this email.<br />
        Your account won't be created until you access the link above and set your password.</p>
      HTML
    end

    it do
      expect(email.delivery_method.settings).to eq(
        address: "smtp",
        port: 2525,
        user_name: App.cuttlefish.smtp_username,
        password: App.cuttlefish.smtp_password,
        # So that we don't get a certificate name and host mismatch we're just
        # disabling the check.
        openssl_verify_mode: "none",
        authentication: :plain
      )
    end
  end

  describe "#reset_password_instructions" do
    let(:admin) { mock_model(Admin) }
    let(:email) { described_class.reset_password_instructions(admin, "abc123", reset_url: "https://foo.com/bar") }

    it do
      expect(email.body.to_s).to eq <<~HTML
        <p>Hello !</p>

        <p>Someone has requested a link to change your password. You can do this through the link below.</p>

        <p><a href="https://foo.com/bar?reset_password_token=abc123">Change my password</a></p>

        <p>If you didn't request this, please ignore this email.</p>
        <p>Your password won't change until you access the link above and create a new one.</p>
      HTML
    end
  end
end
