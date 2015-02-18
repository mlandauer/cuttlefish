# For Sidekiq
class MailWorker
  include Sidekiq::Worker

  def perform(recipients, data, app_id)
    ActiveRecord::Base.transaction do
      # Discard the "return path" in sender
      # Take the from instead from the contents of the mail
      # There can be multiple from addresses in the body of the mail
      # but we'll only take the first
      from = Mail.new(data).from.first

      email = Email.create!(from: from,
        to: recipients.map{|t| t.match("<(.*)>")[1]},
        data: data,
        app_id: app_id)

      email.deliveries.each do |delivery|
        OutgoingDelivery.new(delivery).send
      end
    end
  end
end
