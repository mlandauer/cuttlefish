class MailJob
  attr_reader :message_hash

  def initialize(message_hash)
    @message_hash = message_hash
  end

  def perform
    ActiveRecord::Base.transaction do
      # Just need to extract the Message-ID header. Could do this by parsing the whole email using
      # the Mail gem but this seems wasteful.
      match = message_hash[:data].match(/Message-ID: <([^>]+)>/)
      # Would expect there always to be a message id but we will be more lenient for the time being
      message_id = match[1] if match

      email = Email.create!(from: message_hash[:from].match("<(.*)>")[1],
        to: message_hash[:to].map{|t| t.match("<(.*)>")[1]},
        data: message_hash[:data], message_id: message_id)

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
