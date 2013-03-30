class RawEmail
  attr_reader :from, :to, :data

  def initialize(from, to, data)
    @from, @to, @data = from, to, data
  end

  def record
    Email.create!(:from => from, :to => to.join(', '))
  end

  # Send this mail to another smtp server
  def forward(server, port)
    Net::SMTP.start(server, port) do |smtp|
      smtp.send_message(data, from, to)
    end    
  end
end

class MailJob
  attr_reader :message_hash

  def initialize(message_hash)
    @message_hash = message_hash
  end

  def perform
    email = RawEmail.new(message_hash[:from].match("<(.*)>")[1],
      message_hash[:to].map{|t| t.match("<(.*)>")[1]},
      message_hash[:data])

    email.record
    # Simple pass the message to a local SMTP server (mailcatcher for the time being)
    email.forward('localhost', 1025)
  end
end
