#!/usr/bin/env ruby

require 'mini-smtp-server'
require 'net/smtp'
require 'delayed_job_active_record'
require File.join(File.dirname(__FILE__), 'lib', 'mail_job')

class CuttlefishSmtpServer < MiniSmtpServer
  def new_message_event(message_hash)
    Delayed::Job.enqueue MailJob.new(message_hash)
  end
end

activerecord_config = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config', 'database.yml')))

# Hardcoded to the development environment for the time being
ActiveRecord::Base.establish_connection(activerecord_config["development"])

host = "127.0.0.1"
port = 2525

# Create a new server instance listening at 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections
server = CuttlefishSmtpServer.new(port, host, 4)

# Start the server
server.start

puts "My eight arms and two tentacles are quivering in anticipation."
puts "I'm listening for emails via SMTP on #{host} port #{port}" 

server.join

