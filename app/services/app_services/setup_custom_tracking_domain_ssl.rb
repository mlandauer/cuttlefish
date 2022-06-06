# frozen_string_literal: true

module AppServices
  # For an app with a valid custom_tracking_domain set generate an SSL certificate, setup our web server
  # use it and let the rest of the application to know to use it too
  class SetupCustomTrackingDomainSSL < ApplicationService
    def initialize(app:)
      super()
      @app = app
    end

    def call
      # Double check that we actually do have a custom tracking domain setup
      if app.custom_tracking_domain.blank?
        fail!
        return
      end

      # This will raise an exception if it fails for some reason
      Certificate.new(app.custom_tracking_domain).generate

      # So if we get here that means it worked
      if app.update(custom_tracking_domain_ssl_enabled: true)
        success!
      else
        fail!
      end
    end

    private

    attr_reader :app
  end
end
