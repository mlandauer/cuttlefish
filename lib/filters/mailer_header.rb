class Filters::MailerHeader < Filters::Base
  def filter(content)
    mail = Mail.new(content)
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail.to_s
  end
end
