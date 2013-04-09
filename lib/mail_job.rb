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

      if Rails.env == "development"
        # In development send the mails to mailcatcher
        email.forward('localhost', 1025)
      else
        # Otherwise use whatever the local smtp server is
        email.forward('localhost', 25)
      end
    end
  end
end
