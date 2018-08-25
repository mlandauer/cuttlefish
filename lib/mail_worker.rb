# For Sidekiq
class MailWorker
  include Sidekiq::Worker

  # We require a base64 encoded version of the raw mail data so that it could
  # succesfully serialised as JSON without knowing what encoding it is (which
  # we don't)
  def perform(recipients, base64_encoded_data, app_id)
    ActiveRecord::Base.transaction do
      data = Base64.decode64(base64_encoded_data)

      email = Email.create!(
        to: recipients,
        data: data,
        app_id: app_id
      )

      email.deliveries.each do |delivery|
        OutgoingDelivery.new(delivery).send
      end
    end
  end
end
