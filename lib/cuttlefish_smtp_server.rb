require 'delayed_job_active_record'
require File.expand_path File.join(File.dirname(__FILE__), 'mail_job')
require 'ostruct'
require 'eventmachine'

class CuttlefishSmtpServer
  attr_accessor :connections

  def initialize
    @connections = []
  end

  def start(host = 'localhost', port = 1025)
    @server = EM.start_server host, port, CuttlefishSmtpConnection do |connection|
      connection.server = self
      @connections << connection
      puts "There are now #{@connections.size} open connections..."
    end
  end

  def stop
    if @server
      EM.stop_server @server
      @server = nil
    end
  end

  def running?
    !!@server
  end
end

class CuttlefishSmtpConnection < EM::P::SmtpServer
  attr_accessor :server

  def unbind
    server.connections.delete(self)
    puts "There are now #{server.connections.size} open connections..."
  end

  def receive_plain_auth(user, pass)
    true
  end

  def get_server_domain
    "localhost"
  end

  def get_server_greeting
    "Cuttlefish SMTP server waves its arms and tentacles and says hello"
  end

  def receive_sender(sender)
    current.sender = sender
    true
  end

  def receive_recipient(recipient)
    current.recipients = [] if current.recipients.nil?
    current.recipients << recipient
    true
  end

  def receive_message
    current.received = true
    current.completed_at = Time.now

    Delayed::Job.enqueue MailJob.new(current)

    @current = OpenStruct.new
    true
  end

  def receive_ehlo_domain(domain)
    @ehlo_domain = domain
    true
  end

  def receive_data_command
    current.data = ""
    true
  end

  def receive_data_chunk(data)
    current.data << data.join("\n")
    true
  end

  def receive_transaction
    if @ehlo_domain
      current.ehlo_domain = @ehlo_domain
      @ehlo_domain = nil
    end
    true
  end

  def current
    @current ||= OpenStruct.new
  end
end

