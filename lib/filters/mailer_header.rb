class Filters::MailerHeader < Filters::Base
  attr_accessor :version

  def initialize(options)
    @version = options[:version]
  end
  
  def filter_mail(mail)
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail
  end
end
