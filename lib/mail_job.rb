class MailJob
  attr_reader :message_hash

  def initialize(message_hash)
    @message_hash = message_hash
  end

  def perform
    ActiveRecord::Base.transaction do
      email = Email.create!(from: message_hash[:from].match("<(.*)>")[1],
        to: message_hash[:to].map{|t| t.match("<(.*)>")[1]},
        data: message_hash[:data])

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
