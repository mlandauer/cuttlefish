# For Sidekiq
class MailWorker
  include Sidekiq::Worker
  def perform(sender, recipients, data, received, completed_at, app_id)
    message = OpenStruct.new
    message.sender = sender
    message.recipients = recipients
    message.received = received
    message.completed_at = completed_at
    message.app_id = app_id
    message.data = data
    MailJob.new(message).perform
  end
end
