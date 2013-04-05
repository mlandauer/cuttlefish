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
          log.tail { |line| PostfixLogLine.create_from_line(line) }
        end
      else
        sleep(10)
      end
    end
  end
end
