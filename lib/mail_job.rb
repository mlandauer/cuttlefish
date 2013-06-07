class MailJob
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def perform
    ActiveRecord::Base.transaction do
      email = Email.create!(from: message.sender.match("<(.*)>")[1],
        to: message.recipients.map{|t| t.match("<(.*)>")[1]},
        data: message.data,
        app_id: (message.app_id || App.default.id))

      OutgoingEmail.new(email).send
    end
  end
end
