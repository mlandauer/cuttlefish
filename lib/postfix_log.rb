require 'file/tail'

module PostfixLog
  def self.tail
    # For the benefit of foreman
    $stdout.sync = true

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
    # Assume the log file was written using syslog and parse accordingly
    m = SyslogProtocol.parse("<13>" + line).content.match(/^\S+: (\S+):/)
    m[1] if m
  end

  def self.extract_time_from_postfix_log_line(line)
    SyslogProtocol.parse("<13>" + line).time
  end

  def self.process(line)
    postfix_queue_id = extract_postfix_queue_id_from_line(line)
    email = Email.find_by_postfix_queue_id(postfix_queue_id)
    email.postfix_log_lines.create(text: line)
  end
end
