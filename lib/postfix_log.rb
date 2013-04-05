require 'file/tail'

module PostfixLog
  def self.tail
    File::Tail::Logfile.open("/var/log/mail/mail.log") do |log|
      log.tail { |line| process(line) }
    end
  end

  def self.process(line)
    puts line
  end
end
