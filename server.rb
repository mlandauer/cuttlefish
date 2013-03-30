#!/usr/bin/env ruby -d

require 'mini-smtp-server'
require 'net/smtp'

# This is an SMTP server that logs all
# the messages it receives to STDOUT
class StdoutSmtpServer < MiniSmtpServer

  def new_message_event(message_hash)
    # TODO: Put the handler job into a delayed job queue

    # For the time being just do it here to keep things super simple

    puts "# New email received:"
    puts "-- From: #{message_hash[:from]}"
    puts "-- To:   #{message_hash[:to]}"
    puts "--"
    puts "-- " + message_hash[:data].gsub(/\r\n/, "\r\n-- ")
    puts

    # Simple pass the message to a local SMTP server (mailcatcher for the time being)
    Net::SMTP.start('localhost', 1025) do |smtp|
      # Use the SMTP object smtp only in this block.
      smtp.send_message(message_hash[:data], message_hash[:from], message_hash[:to])
    end
  end

end

# Create a new server instance listening at 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections
server = StdoutSmtpServer.new(2525, "127.0.0.1", 4)

# Start the server
server.start

server.join
