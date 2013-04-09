require File.expand_path File.join(File.dirname(__FILE__), 'cuttlefish_smtp_server')

module CuttlefishControl
  def self.smtp_start
    environment = ENV["RAILS_ENV"] || "development"
    host = "127.0.0.1"
    port = 2525

    # For the benefit of foreman
    $stdout.sync = true

    activerecord_config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')))
    ActiveRecord::Base.establish_connection(activerecord_config[environment])

    EM.run {
      CuttlefishSmtpServer.new.start(host, port)

      puts "My eight arms and two tentacles are quivering in anticipation."
      puts "I'm listening for emails via SMTP on #{host} port #{port}"
      puts "I'm in the #{environment} environment" 
    }
  end

  def self.log_start
    # For the benefit of foreman
    $stdout.sync = true

    file = "/var/log/mail/mail.log"
    puts "Sucking up log entries in #{file}..."
    while true
      if File.exists?(file)
        File::Tail::Logfile.open(file) do |log|
          log.tail { |line| PostfixLogLine.create_from_line(line) }
        end
      else
        sleep(10)
      end
    end
  end
end
