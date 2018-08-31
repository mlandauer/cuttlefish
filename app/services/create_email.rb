class CreateEmail < ApplicationService
  def initialize(app_id:, from:, to:, cc:, subject:, text_part:, html_part:)
    @app_id = app_id
    @from = from
    @to = to
    @cc = cc
    @subject = subject
    @text_part = text_part
    @html_part = html_part
  end

  def call
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
    email
  end

  private

  attr_reader :app_id, :from, :to, :cc, :subject, :text_part, :html_part
end
