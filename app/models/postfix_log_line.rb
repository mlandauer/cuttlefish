class PostfixLogLine < ActiveRecord::Base
  belongs_to :email

  def self.create_from_line(line)
    # Only log delivery attempts
    if program(line) == "smtp"
      queue_id = queue_id(line)
      time = time(line)
      text = program_content(line)
      # TODO: Should find the most recent email with the queue ID (as there may be several)
      email = Email.find_by_postfix_queue_id(queue_id)
      if email
        # Don't resave duplicates
        find_or_create_by(time: time, text: text, email: email)
      else
        puts "Skipping postfix queue id #{queue_id} - it's not recognised"
      end
    end
  end

  def self.queue_id(line)
    match_main_content(line)[:queue_id]
  end

  def self.time(line)
    parse_postfix_log_line(line).time
  end

  def self.program(line)
    match_main_content(line)[:program]
  end

  def self.program_content(line)
    match_main_content(line)[:program_content]
  end

  private

  def self.match_main_content(line)
    m = parse_postfix_log_line(line).content.match /^postfix\/(\w+)\[(\d+)\]: (([0-9A-F]+): )?(.*)/
    {:program => m[1], :pid => m[2], :queue_id => m[4], :program_content => m[5]}
  end

  def self.parse_postfix_log_line(line)
    # Assume the log file was written using syslog and parse accordingly
    SyslogProtocol.parse("<13>" + line)
  end
end
