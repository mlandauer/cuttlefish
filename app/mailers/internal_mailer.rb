class InternalMailer < Devise::Mailer
  # Send mail directly to postfix - don't bother sending it through Cuttlefish first.
  # That way we don't need a special app and all the associate nonsense
  default delivery_method_options: {
    address: Rails.configuration.postfix_smtp_host,
    port: Rails.configuration.postfix_smtp_port,
    # Disabling TLS so that it doesn't bother encrypting this connection
    # and also won't fail because the servername doesn't match the certificate
    # TODO This should all be configurable and not like this quick little hack. Eek!
    enable_starttls_auto: false
  }

  def invitation_instructions(record, token, opts={})
    opts[:subject] = "#{record.invited_by.display_name} invites you to Cuttlefish"
    super
  end
end
