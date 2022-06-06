# frozen_string_literal: true

module AppServices
  class Update < ApplicationService
    VALID_ATTRIBUTES = %i[
      name
      open_tracking_enabled
      click_tracking_enabled
      custom_tracking_domain
      from_domain
      dkim_enabled
      webhook_url
    ].freeze

    def initialize(
      current_admin:,
      id:,
      attributes:
    )
      super()
      @current_admin = current_admin
      @id = id
      @attributes = attributes.select { |k, _v| VALID_ATTRIBUTES.include?(k) }
    end

    def call
      app = App.find(id)
      Pundit.authorize(current_admin, app, :update?)
      # If we're changing the custom tracking domain then reset the related ssl setting
      # TODO: We probably also want to delete the old certificate, private key and nginx config on disk and reload nginx
      if attributes.key?(:custom_tracking_domain) && attributes[:custom_tracking_domain] != app.custom_tracking_domain
        attributes[:custom_tracking_domain_ssl_enabled] = false
      end

      # TODO: If we're updating the custom_tracking_domain then also start generation of certificate
      if app.update(attributes)
        success!
      else
        fail!
      end
      app
    end

    private

    attr_reader :current_admin, :id, :attributes
  end
end
