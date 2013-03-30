class MailJob
  attr_reader :message_hash

  def initialize(message_hash)
    @message_hash = message_hash
  end

  def perform
    puts "# New email received:"
    puts "-- From: #{message_hash[:from]}"
    puts "-- To:   #{message_hash[:to]}"
    puts "--"
    puts "-- " + message_hash[:data].gsub(/\r\n/, "\r\n-- ")
    puts

    record
    forward('localhost', 1025)
  end

  def record
    Email.create!(:from => message_hash[:from], :to => message_hash[:to])
  end

  # Send this mail to another smtp server
  def forward(server, port)
    # Simple pass the message to a local SMTP server (mailcatcher for the time being)
    Net::SMTP.start(server, port) do |smtp|
      # Use the SMTP object smtp only in this block.
      smtp.send_message(message_hash[:data], message_hash[:from], message_hash[:to])
    end    
  end
end
