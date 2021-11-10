# frozen_string_literal: true

class CuttlefishLogDaemon
  def self.start(file, logger)
    loop do
      if File.exist?(file)
        File::Tail::Logfile.open(file) do |log|
          log.tail { |line| PostfixLogLineServices::Create.call(line, logger) }
        end
      else
        sleep(10)
      end
    end
  rescue SignalException => e
    raise e if e.to_s != "SIGTERM"

    logger.info "Received SIGTERM. Shutting down..."
  end
end
