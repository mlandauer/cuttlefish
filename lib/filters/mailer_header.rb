class Filters::MailerHeader < Filters::Base
  def filter_mail(mail)
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail
  end
end
