# frozen_string_literal: true

# For Sidekiq
class PostDeliveryEventWorker
  include Sidekiq::Worker

  def perform(url, key, id)
    event = PostfixLogLine.find(id)
    WebhookServices::PostDeliveryEvent.call(
      url: url,
      key: key,
      event: event
    )
  end
end
