# frozen_string_literal: true

module AppServices
  class Create < ApplicationService
    def initialize(
      current_admin:, name:, open_tracking_enabled:, click_tracking_enabled:,
      custom_tracking_domain:, from_domain:, dkim_enabled:
    )
      @current_admin = current_admin
      @attributes = {
        name: name,
        open_tracking_enabled: open_tracking_enabled,
        click_tracking_enabled: click_tracking_enabled,
        custom_tracking_domain: custom_tracking_domain,
        from_domain: from_domain,
        dkim_enabled: dkim_enabled
      }
    end

    def call
      app = App.new(@attributes.merge(team: current_admin.team))
      Pundit.authorize(current_admin, app, :create?)
      if app.save
        success!
      else
        fail! OpenStruct.new(
          type: :save,
          message: "Save failed"
        )
      end
      app
    end

    private

    attr_reader :current_admin, :attributes
  end
end
