class Filters::MailerHeader < Filters::Delivery
  def data(content)
    mail = Mail.new(input_data(content))
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail.to_s
  end
end
