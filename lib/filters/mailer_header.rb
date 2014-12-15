class Filters::MailerHeader < Filters::Delivery
  def data(delivery)
    mail = Mail.new(input_data(delivery))
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail.to_s
  end
end
