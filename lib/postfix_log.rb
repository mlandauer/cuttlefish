require 'file/tail'

module PostfixLog
  def self.tail
    # For the benefit of foreman
    $stdout.sync = true

    environment = ENV["RAILS_ENV"] || "development"

    activerecord_config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')))
    ActiveRecord::Base.establish_connection(activerecord_config[environment])

    file = "/var/log/mail/mail.log"
    puts "Sucking up log entries in #{file}..."
    while true
      if File.exists?(file)
        File::Tail::Logfile.open(file) do |log|
          log.tail { |line| process(line) }
        end
      else
        sleep(10)
      end
    end
  end

  def self.extract_postfix_queue_id_from_line(line)
    m = extract_main_content_postfix_log_line(line).match(/^\S+: (\S+):/)
    m[1] if m
  end

  def self.extract_time_from_postfix_log_line(line)
    parse_postfix_log_line(line).time
  end

  def self.process(line)
    queue_id = extract_postfix_queue_id_from_line(line)
    email = Email.find_by_postfix_queue_id(queue_id)
    if email
      # Don't resave duplicates
      email.postfix_log_lines.find_or_create_by(time: extract_time_from_postfix_log_line(line),
        text: extract_main_content_postfix_log_line(line))
    else
      puts "Skipping postfix queue id #{queue_id} - it's not recognised"
    end
  end

  private

  def self.extract_main_content_postfix_log_line(line)
    parse_postfix_log_line(line).content
  end

  def self.parse_postfix_log_line(line)
    # Assume the log file was written using syslog and parse accordingly
    SyslogProtocol.parse("<13>" + line)
  end
end
