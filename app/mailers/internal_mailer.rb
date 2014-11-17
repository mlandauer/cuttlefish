class InternalMailer < Devise::Mailer
  after_action :set_delivery_options

  private

  def set_delivery_options
    mail.delivery_method.settings.merge!(
      address: "localhost",
      port: Rails.configuration.cuttlefish_smtp_port,
      user_name: App.default.smtp_username,
      password: App.default.smtp_password,
      # Server is currently using a self-signed certificate
      openssl_verify_mode: "none",
      authentication: :plain
    )
  end
end
