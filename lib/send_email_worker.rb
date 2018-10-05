# frozen_string_literal: true

# For Sidekiq
class SendEmailWorker
  include Sidekiq::Worker

  def perform(email_id)
    ActiveRecord::Base.transaction do
      EmailServices::Send.call(email: Email.find(email_id))
    end
  end
end
