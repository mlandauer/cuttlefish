# For Sidekiq
class MailWorker
  include Sidekiq::Worker

  def perform(email_id)
    ActiveRecord::Base.transaction do
      email = Email.find(email_id)

      email.deliveries.each do |delivery|
        OutgoingDelivery.new(delivery).send
      end
    end
  end
end
