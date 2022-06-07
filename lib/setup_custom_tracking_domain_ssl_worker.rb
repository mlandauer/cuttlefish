# frozen_string_literal: true

# For Sidekiq
class SetupCustomTrackingDomainSSLWorker
  include Sidekiq::Worker

  def perform(app_id)
    app = App.find(app_id)
    AppServices::SetupCustomTrackingDomainSSL.call(app: app)
    # TODO: Check whether that worked
  end
end
