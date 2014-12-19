class Filters::MailerHeader < Filters::Base
  def filter(content)
    filter_mail(Mail.new(content)).to_s
  end

  def filter_mail(mail)
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail
  end
end
