class MailJob
  attr_reader :message_hash

  def initialize(message_hash)
    @message_hash = message_hash
  end

  def perform
    email = Email.create!(from: message_hash[:from].match("<(.*)>")[1],
      to: message_hash[:to].map{|t| t.match("<(.*)>")[1]},
      data: message_hash[:data])

    # Simple pass the message to a local SMTP server (mailcatcher for the time being)
    email.forward('localhost', 1025)
  end
end
