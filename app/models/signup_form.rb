class SignupForm < MailForm::Base
  attribute :name
  attribute :email
  attribute :organisation_name
  attribute :organisation_url
  attribute :message

  def headers
    {
      subject: "Access request for cuttlefish.oaf.org.au",
      to: "contact@oaf.org.au",
      from: %("#{name}" <#{email}>),
      # This configuration is shared with devise.
      # TODO Can't we just make this the default configuration for sending all mail?
      delivery_method_options: {
        address: Rails.configuration.cuttlefish_domain,
        port: Rails.configuration.cuttlefish_smtp_port,
        user_name: App.cuttlefish.smtp_username,
        password: App.cuttlefish.smtp_password,
        # So that we don't get a certificate name and host mismatch we're just
        # disabling the check.
        openssl_verify_mode: "none",
        authentication: :plain
      }
    }
  end
end
