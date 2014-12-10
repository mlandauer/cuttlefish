require File.expand_path File.join(File.dirname(__FILE__), 'cuttlefish_smtp_server')

module CuttlefishControl
  def self.smtp_start
    environment = ENV["RAILS_ENV"] || "development"
    # We are accepting connections from the outside world
    host = "0.0.0.0"
    port = Rails.configuration.cuttlefish_smtp_port

    # For the benefit of foreman
    $stdout.sync = true

    if read_only_mode?
      puts "I'm in read-only mode and so not listening for emails via SMTP."
      puts how_to_disable_read_only_mode
      # Sleep forever
      sleep
    else
      activerecord_config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')))
      ActiveRecord::Base.establish_connection(activerecord_config[environment])

      EM.run {
        CuttlefishSmtpServer.new.start(host, port)

        puts "My eight arms and two tentacles are quivering in anticipation."
        puts "I'm listening for emails via SMTP on #{host} port #{port}"
        puts "I'm in the #{environment} environment"
      }
    end
  end

  def self.log_start
    # For the benefit of foreman
    $stdout.sync = true

    file = "/var/log/mail/mail.log"

    if read_only_mode?
      puts "I'm in read-only mode and so not sucking up log entries."
      puts how_to_disable_read_only_mode
      # Sleep forever
      sleep
    else
      puts "Sucking up log entries in #{file}..."
      CuttlefishLogDaemon.start(file)
    end
  end

  private

  def self.read_only_mode?
    Rails.configuration.cuttlefish_read_only_mode
  end

  def self.how_to_disable_read_only_mode
    "To disable unset the environment variable CUTTLEFISH_READ_ONLY_MODE and restart."
  end
end
