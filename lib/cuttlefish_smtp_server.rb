# frozen_string_literal: true

require File.expand_path File.join(File.dirname(__FILE__), "parse_headers_create_email_worker")
require File.expand_path File.join(File.dirname(__FILE__), "email_data_cache")
require "ostruct"
require "eventmachine"
require "mail"
require File.expand_path File.join(
  File.dirname(__FILE__), "..", "app", "models", "application_record"
)
require File.expand_path File.join(
  File.dirname(__FILE__), "..", "app", "models", "app"
)
require File.expand_path File.join(
  File.dirname(__FILE__), "..", "app", "models", "email"
)
require File.expand_path File.join(
  File.dirname(__FILE__), "..", "app", "models", "address"
)
require File.expand_path File.join(
  File.dirname(__FILE__), "..", "app", "models", "delivery"
)

class CuttlefishSmtpServer
  attr_accessor :connections
  attr_reader :logger

  def initialize(logger)
    @connections = []
    @logger = logger
  end

  def start(host = "localhost", port = 1025)
    trap("TERM") do
      logger.info "Received SIGTERM"
      stop
    end
    trap("INT") do
      logger.info "Received SIGINT"
      stop!
    end
    @server = EM.start_server host,
                              port,
                              CuttlefishSmtpConnection do |connection|
      connection.server = self
      @connections << connection
    end
  end

  # Gracefull shutdown
  def stop
    logger.info "Stopping server gracefully..."
    EM.stop_server @server

    return if wait_for_connections_and_stop

    # Still some connections running, schedule a check later
    EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
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
    logger.info "Stopping server quickly..."
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

  # rubocop:disable Naming/AccessorMethodName
  def get_server_domain
    Rails.configuration.cuttlefish_smtp_host
  end

  def get_server_greeting
    "Cuttlefish SMTP server waves its arms and tentacles and says hello"
  end
  # rubocop:enable Naming/AccessorMethodName

  def receive_sender(sender)
    current.sender = sender
    true
  end

  def receive_recipient(recipient)
    current.recipients = [] if current.recipients.nil?
    # Convert "<foo@foo.com>" to foo@foo.com
    current.recipients << recipient.match("<(.*)>")[1]
    true
  end

  # This is copied from
  # https://github.com/eventmachine/eventmachine/blob/master/lib/em/protocols/smtpserver.rb
  # so that it can be monkey-patched. We don't want to completely clear out the
  # state at the end of a succesfull transaction, especially the auth
  # information. That's why the `reset_protocol_state` is commented out in the
  # succeeded proc.
  # TODO: Put in an upstream patch to address this at source
  def process_data_line(line)
    if line == "."
      unless @databuffer.empty?
        receive_data_chunk @databuffer
        @databuffer.clear
      end

      succeeded = proc {
        send_data "250 Message accepted\r\n"
        # reset_protocol_state
      }
      failed = proc {
        send_data "550 Message rejected\r\n"
        reset_protocol_state
      }
      d = receive_message

      if d.respond_to?(:set_deferred_status)
        d.callback(&succeeded)
        d.errback(&failed)
      else
        (d ? succeeded : failed).call
      end

      @state -= %i[data mail_from rcpt]
    else
      # slice off leading . if any
      line.slice!(0...1) if line[0] == "."
      @databuffer << line
      if @databuffer.length > @@parms[:chunksize]
        receive_data_chunk @databuffer
        @databuffer.clear
      end
    end
  end

  def receive_message
    current.received = true
    # rubocop:disable Rails/TimeZone
    current.completed_at = Time.now
    # rubocop:enable Rails/TimeZone

    # TODO: No need to capture current.sender, current.received,
    # current.completed_at because we're not passing it on

    # Store content of email in a temporary file
    # Note that this depends on having access to the same filesystem as
    # the worker processes have access to. Currently, that's fine because we're
    # running everything on a single machine but that assumption might not be
    # true in the future
    # Using Tempfile.create rather than Tempfile.new so that the tmp file is
    # not automatically deleted through garbage collection
    file = Tempfile.create("cuttlefish", encoding: "ascii-8bit")
    file.write(current.data)
    file.close

    # Note the worker will delete the temporary file when it's done
    ParseHeadersCreateEmailWorker.perform_async(
      current.recipients,
      file.path,
      current.app_id
    )

    # Preserve the app_id as we are already authenticated
    @current = OpenStruct.new(app_id: current.app_id)
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
    current.data = +""
    true
  end

  def receive_data_chunk(data)
    current.data << data.join("\r\n")
    true
  end

  def current
    @current ||= OpenStruct.new
  end
end
