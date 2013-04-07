class PostfixLogLine < ActiveRecord::Base
  belongs_to :email

  def delivered?
    main_content_info[:dsn] == "2.0.0"
  end

  def main_content_info
    PostfixLogLine.extract_main_content_info(text)
  end

  def self.extract_main_content_info(program_content)
    {
      to: program_content.match(/to=<([^>]+)>/)[1],
      relay: program_content.match(/relay=([^,]+)/)[1],
      delay: program_content.match(/delay=([^,]+)/)[1],
      delays: program_content.match(/delays=([^,]+)/)[1],
      dsn: program_content.match(/dsn=([^,]+)/)[1],
      status: program_content.match(/status=(.*)$/)[1]
    }
  end

  def self.create_from_line(line)
    values = match_main_content(line)

    # Only log delivery attempts
    if values[:program] == "smtp"
      # TODO: Should find the most recent email with the queue ID (as there may be several)
      email = Email.find_by_postfix_queue_id(values[:queue_id])
      if email
        # Don't resave duplicates
        find_or_create_by(time: values[:time], text: values[:program_content], email: email)
        email.reload
        email.update_delivery_status!
      else
        puts "Skipping postfix queue id #{values[:queue_id]} - it's not recognised"
      end
    end
  end

  def self.match_main_content(line)
    # Assume the log file was written using syslog and parse accordingly
    p = SyslogProtocol.parse("<13>" + line)
    m = p.content.match /^postfix\/(\w+)\[(\d+)\]: (([0-9A-F]+): )?(.*)/
    {:time => p.time, :program => m[1], :pid => m[2], :queue_id => m[4], :program_content => m[5]}
  end
  
end
