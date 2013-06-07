class TestMailer < ActionMailer::Base
  def test_email(app, params)
    @text = params[:text]
    e = mail(from: params[:from], to: params[:to], cc: params[:cc], subject: params[:subject])
    e.delivery_method :smtp, {
        address: "localhost",
        port: Rails.configuration.cuttlefish_smtp_port,
        user_name: app.smtp_username,
        password: app.smtp_password,
        authentication: :plain
      }
    e
  end
end
