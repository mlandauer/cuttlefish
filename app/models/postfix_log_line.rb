class PostfixLogLine < ActiveRecord::Base
  belongs_to :email

  def delivered?
    dsn == "2.0.0"
  end

  def self.create_from_line(line)
    values = match_main_content(line)

    # Only log delivery attempts
    if values[:program] == "smtp"
      # TODO: Should find the most recent email with the queue ID (as there may be several)
      email = Email.find_by_postfix_queue_id(values[:queue_id])
      if email
        # Don't resave duplicates
        find_or_create_by(email: email, time: values[:time], text: values[:program_content],
          to: values[:to], relay: values[:relay], delay: values[:delay], delays: values[:delays],
          dsn: values[:dsn], status: values[:status])
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
    content_match = p.content.match /^postfix\/(\w+)\[(\d+)\]: (([0-9A-F]+): )?(.*)/
    program_content = content_match[5]
    to_match = program_content.match(/to=<([^>]+)>/)
    relay_match = program_content.match(/relay=([^,]+)/)
    delay_match = program_content.match(/delay=([^,]+)/)
    delays_match = program_content.match(/delays=([^,]+)/)
    dsn_match = program_content.match(/dsn=([^,]+)/)
    status_match = program_content.match(/status=(.*)$/)

    result = {
      :time => p.time,
      :program => content_match[1],
      :pid => content_match[2],
      :queue_id => content_match[4],
      :program_content => program_content
    }
    result[:to] = to_match[1] if to_match
    result[:relay] = relay_match[1] if relay_match
    result[:delay] = delay_match[1] if delay_match
    result[:delays] = delays_match[1] if delays_match
    result[:dsn] = dsn_match[1] if dsn_match
    result[:status] = status_match[1] if status_match

    result
  end

end
