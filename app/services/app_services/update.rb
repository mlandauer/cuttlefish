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
      if app.update_attributes(attributes)
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
