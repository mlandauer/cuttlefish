require File.expand_path File.join(File.dirname(__FILE__), 'mail_worker')
require 'ostruct'
require 'eventmachine'
require 'mail'
require File.expand_path File.join(File.dirname(__FILE__), "..", "app", "models", "app")

class CuttlefishSmtpServer
  attr_accessor :connections

  def initialize
    @connections = []
  end

  def start(host = 'localhost', port = 1025)
    trap("TERM") {
      puts "Received SIGTERM"
      stop
    }
    trap("INT") {
      puts "Received SIGINT"
      stop!
    }
    @server = EM.start_server host, port, CuttlefishSmtpConnection do |connection|
      connection.server = self
      @connections << connection
    end
  end

  # Gracefull shutdown
  def stop
    puts "Stopping server gracefully..."
    EM.stop_server @server

    unless wait_for_connections_and_stop
      # Still some connections running, schedule a check later
      EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
    end
  end

  def wait_for_connections_and_stop
    if @connections.empty?
      EventMachine.stop
      true
    else
      false
    end
  end

  # Forceful shutdown
  def stop!
    puts "Stopping server quickly..."
    if @server
      EM.stop_server @server
      @server = nil
    end
    exit
  end
end

class CuttlefishSmtpConnection < EM::P::SmtpServer
  attr_accessor :server

  def initialize
    super
    self.parms = CuttlefishSmtpConnection.default_parameters
  end

  def self.default_parameters
    parameters = {
      auth: :required,
      starttls: :required
    }
    # Don't use our own SSL certificate in development
    unless Rails.env.development?
      parameters[:starttls_options] = {
        cert_chain_file: Rails.configuration.cuttlefish_domain_cert_chain_file,
        private_key_file: Rails.configuration.cuttlefish_domain_private_key_file
      }
    end
    parameters
  end

  def unbind
    server.connections.delete(self)
  end

  def get_server_domain
    Rails.configuration.cuttlefish_domain
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

    # TODO No need to capture current.sender, current.received, current.completed_at
    # because we're not passing it on
    #
    # Before we send current.data to MailWorker we need to deal with the encoding
    # because before it gets stored in redis it needs to be serialised to json
    # which requires a conversion to utf8
    # It comes in with unknown encoding - so let's encode it as base64
    MailWorker.perform_async(current.recipients, Base64.encode64(current.data), current.app_id)

    @current = OpenStruct.new
    true
  end

  def receive_plain_auth(user, password)
    # This currently will only check the authentication if it's sent
    # In other words currently the authentication is optional
    app = App.where(smtp_username: user).first
    if app && app.smtp_password == password
      current.app_id = app.id
      true
    else
      false
    end
  end

  def receive_data_command
    current.data = ""
    true
  end

  def receive_data_chunk(data)
    current.data << data.join("\n")
    true
  end

  def current
    @current ||= OpenStruct.new
  end
end
