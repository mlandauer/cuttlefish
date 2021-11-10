# frozen_string_literal: true

require File.expand_path File.join(
  File.dirname(__FILE__), "cuttlefish_smtp_server"
)

class CuttlefishControl
  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def smtp_start
    environment = ENV["RAILS_ENV"] || "development"
    # We are accepting connections from the outside world
    host = "0.0.0.0"
    port = Rails.configuration.cuttlefish_smtp_port

    # For the benefit of foreman
    $stdout.sync = true

    if read_only_mode?
      logger.info "I'm in read-only mode and so not listening for emails via SMTP."
      logger.info how_to_disable_read_only_mode
      # Sleep forever
      sleep
    else
      activerecord_config = YAML.safe_load(
        File.read(
          File.join(File.dirname(__FILE__), "..", "config", "database.yml")
        )
      )
      ActiveRecord::Base.establish_connection(activerecord_config[environment])

      EM.run do
        CuttlefishSmtpServer.new(logger).start(host, port)

        logger.info "My eight arms and two tentacles are quivering in anticipation."
        logger.info "I'm listening for emails via SMTP on #{host} port #{port}"
        logger.info "I'm in the #{environment} environment"
      end
    end
  end

  def log_start
    # For the benefit of foreman
    # TODO: Move this to where the logger is being setup
    $stdout.sync = true

    if read_only_mode?
      logger.info "I'm in read-only mode and so not sucking up log entries."
      logger.info how_to_disable_read_only_mode
      # Sleep forever
      sleep
    else
      logger.info "Sucking up log entries in #{Rails.configuration.postfix_log_path}..."
      CuttlefishLogDaemon.start(Rails.configuration.postfix_log_path, logger)
    end
  end

  def read_only_mode?
    Rails.configuration.cuttlefish_read_only_mode
  end

  def how_to_disable_read_only_mode
    "To disable unset the environment variable CUTTLEFISH_READ_ONLY_MODE " \
      "and restart."
  end
end
