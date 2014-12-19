class Filters::MailerHeader < Filters::Delivery
  def data(delivery)
    data2(delivery.data)
  end

  def data2(content)
    mail = Mail.new(input_data2(content))
    mail.header['X-Mailer'] = "Cuttlefish #{APP_VERSION}"
    mail.to_s
  end
end
