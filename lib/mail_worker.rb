# For Sidekiq
class MailWorker
  include Sidekiq::Worker

  # We require a base64 encoded version of the raw mail data so that it could
  # succesfully serialised as JSON without knowing what encoding it is (which
  # we don't)
  def perform(recipients, base64_encoded_data, app_id)
    ActiveRecord::Base.transaction do
      # Discard the "return path" in sender
      # Take the from instead from the contents of the mail
      # There can be multiple from addresses in the body of the mail
      # but we'll only take the first
      data = Base64.decode64(base64_encoded_data)
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
