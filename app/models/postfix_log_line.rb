# frozen_string_literal: true

class PostfixLogLine < ApplicationRecord
  belongs_to :delivery, inverse_of: :postfix_log_lines

  after_save :update_status!

  def dsn_class
    match = dsn.match(/^(\d)\.(\d+)\.(\d+)/)
    raise "Unexpected form for dsn code" if match.nil?

    match[1].to_i
  end

  def status
    if dsn_class == 2
      "delivered"
    # Mailbox full should be treated as a temporary problem
    elsif dsn_class == 4 || dsn == "5.2.2"
      "soft_bounce"
    elsif dsn_class == 5
      "hard_bounce"
    else
      raise "Unknown dsn class"
    end
  end

  # My status has changed. Tell those effected.
  def update_status!
    delivery.save!
  end

  # TODO: We don't want to be using logger here
  def self.create_from_line(line, logger)
    values = match_main_content(line, logger)
    return if values.nil?

    program = values.delete(:program)
    to = values.delete(:to)
    queue_id = values.delete(:queue_id)

    # Only log delivery attempts
    # Note that timeouts in connecting to the remote mail server appear in
    # the program "error". So, we're including those
    return unless %w[smtp error].include?(program)

    delivery = Delivery.joins(:email, :address)
                       .order("emails.created_at DESC")
                       .find_by(
                         "addresses.text" => to,
                         postfix_queue_id: queue_id
                       )

    if delivery
      a = values.merge(delivery_id: delivery.id)
      # Don't resave duplicates and return nil if it was a duplicate
      PostfixLogLine.create!(a) if PostfixLogLine.find_by(a).nil?
    else
      logger.info "Skipping address #{to} from postfix queue id #{queue_id} - " \
                  "it's not recognised: #{line}"
      nil
    end
  end

  # TODO: We don't want to be using logger here
  def self.match_main_content(line, logger)
    # Assume the log file was written using syslog and parse accordingly
    # rubocop:disable Style/StringConcatenation
    p = SyslogProtocol.parse("<13>" + line)
    # rubocop:enable Style/StringConcatenation
    content_match =
      p.content.match %r{^postfix/(\w+)\[(\d+)\]: (([0-9A-F]+): )?(.*)}
    if content_match.nil?
      logger.info "Skipping unrecognised line: #{line}"
      return nil
    end

    program_content = content_match[5]
    to_match = program_content.match(/to=<([^>]+)>/)
    relay_match = program_content.match(/relay=([^,]+)/)
    delay_match = program_content.match(/delay=([^,]+)/)
    delays_match = program_content.match(/delays=([^,]+)/)
    dsn_match = program_content.match(/dsn=([^,]+)/)
    status_match = program_content.match(/status=(.*)$/)

    result = {
      time: p.time,
      program: content_match[1],
      queue_id: content_match[4]
    }
    result[:to] = to_match[1] if to_match
    result[:relay] = relay_match[1] if relay_match
    result[:delay] = delay_match[1] if delay_match
    result[:delays] = delays_match[1] if delays_match
    result[:dsn] = dsn_match[1] if dsn_match
    result[:extended_status] = status_match[1] if status_match

    result
  end
end
