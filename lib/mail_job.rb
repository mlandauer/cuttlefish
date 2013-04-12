class MailJob
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def perform
    ActiveRecord::Base.transaction do
      email = Email.create!(from: message.sender.match("<(.*)>")[1],
        to: message.recipients.map{|t| t.match("<(.*)>")[1]},
        data: message.data)

      email.forward(Rails.configuration.postfix_smtp_host, Rails.configuration.postfix_smtp_port)
    end
  end
end
