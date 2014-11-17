class InternalMailer < Devise::Mailer
  after_action :set_delivery_options

  private

  def set_delivery_options
    # Send mail directly to postfix - don't bother sending it
    # through Cuttlefish first.
    mail.delivery_method.settings.merge!(
      address: Rails.configuration.postfix_smtp_host,
      port: Rails.configuration.postfix_smtp_port
    )
  end
end
