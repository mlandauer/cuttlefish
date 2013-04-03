require 'mini-smtp-server'
require 'delayed_job_active_record'
require 'mail_job'

class CuttlefishSmtpServer < MiniSmtpServer
  def new_message_event(message_hash)
    # This doesn't currently correctly capture emails sent to multiple recipients
    Delayed::Job.enqueue MailJob.new(message_hash)
  end

  def connecting(client)
    # Only accept local connections
    # We're currently only listening on the local address so this extra check is not
    # strictly necessary
    client.peeraddr[3] == "127.0.0.1"
  end
end
