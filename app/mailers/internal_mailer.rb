class InternalMailer < Devise::Mailer
  default delivery_method_options: {
    address: Rails.configuration.cuttlefish_domain,
    port: Rails.configuration.cuttlefish_smtp_port,
    user_name: App.cuttlefish.smtp_username,
    password: App.cuttlefish.smtp_password,
    # So that we don't get a certificate name and host mismatch we're just
    # disabling the check.
    openssl_verify_mode: "none",
    authentication: :plain
  }

  def invitation_instructions(record, token, opts={})
    opts[:subject] = "#{record.invited_by.display_name} invites you to Cuttlefish"
    super
  end
end
