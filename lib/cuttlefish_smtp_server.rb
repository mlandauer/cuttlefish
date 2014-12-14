require 'delayed_job_active_record'
require File.expand_path File.join(File.dirname(__FILE__), 'mail_job')
require 'ostruct'
require 'eventmachine'
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
      # On every new connection check if the authentication setting has changed
      connection.parms = {
        auth: :required,
        starttls: :required,
        tls_options: {
          # TODO Rename the certificate to generic name that doesn't include domain
          # TODO Allow paths to be overridden in environment
          cert_chain_file: "/etc/ssl/cuttlefish.oaf.org.au.pem",
          private_key_file: "/etc/ssl/private/cuttlefish.oaf.org.au.key"
        }
      }
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

  def running?
    !!@server
  end
end

class CuttlefishSmtpConnection < EM::P::SmtpServer
  attr_accessor :server

  def unbind
    server.connections.delete(self)
  end

  def receive_plain_auth(user, pass)
    true
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

    Delayed::Job.enqueue MailJob.new(current)

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

  # Overriding implementation in parent class
  # TODO Add this feature to supply certificate as PR in main project (it's listed as a TODO)
  def process_starttls
    if @@parms[:starttls]
      if @state.include?(:starttls)
        send_data "503 TLS Already negotiated\r\n"
      elsif ! @state.include?(:ehlo)
        send_data "503 EHLO required before STARTTLS\r\n"
      else
        send_data "220 Start TLS negotiation\r\n"
        start_tls(@@parms[:tls_options] || {})
        @state << :starttls
      end
    else
      process_unknown
    end
  end
end
