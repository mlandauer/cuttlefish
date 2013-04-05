class PostfixLogLine < ActiveRecord::Base
  belongs_to :email

  def self.create_from_line(line)
    queue_id = PostfixLog.extract_postfix_queue_id_from_line(line)
    time = PostfixLog.extract_time_from_postfix_log_line(line)
    text = PostfixLog.extract_main_content_postfix_log_line(line)

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
