class CreateEmail
  def self.call(app_id:, from:, to:, cc:, subject:, text_part:, html_part:)
    mail = Mail.new
    mail.from = from
    mail.to = to
    mail.cc = cc
    mail.subject = subject

    part = Mail::Part.new
    part.body = text_part
    mail.text_part = part

    part = Mail::Part.new
    part.body = html_part
    mail.html_part = part

    email = Email.create!(
      to: mail.to,
      data: mail.to_s,
      app_id: app_id
    )

    MailWorker.perform_async(email.id)
  end
end
