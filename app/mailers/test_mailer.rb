class TestMailer < ActionMailer::Base
  def test_email(app, params)
    @text = params[:text]
    e = mail(from: params[:from], to: params[:to], cc: params[:cc], subject: params[:subject])
    e.delivery_method :smtp, {
        # We're connecting to localhost so that on local vm we don't need
        # to put anything in /etc/hosts for the name to resolve. This has some consequences
        # for the SSL connection (see below)
        address: Rails.env.development? ? "smtp" : "localhost",
        port: Rails.configuration.cuttlefish_smtp_port,
        user_name: app.smtp_username,
        password: app.smtp_password,
        # So that we don't get a certificate name and host mismatch we're just
        # disabling the check.
        openssl_verify_mode: "none",
        authentication: :plain
      }
    e
  end
end
