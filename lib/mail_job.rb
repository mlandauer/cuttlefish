class MailJob
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def perform
    ActiveRecord::Base.transaction do
      # Discard the "return path" in message.sender
      # Take the from instead from the contents of the mail
      # There can be multiple from addresses in the body of the mail
      # but we'll only take the first
      from = Mail.new(message.data).from.first

      email = Email.create!(from: from,
        to: message.recipients.map{|t| t.match("<(.*)>")[1]},
        data: message.data,
        app_id: message.app_id)

      OutgoingEmail.new(email).send
    end
  end
end
