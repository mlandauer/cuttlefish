# frozen_string_literal: true

module AppServices
  class UpgradeDkim < ApplicationService
    def initialize(
      current_admin:,
      id:
    )
      super()
      @current_admin = current_admin
      @id = id
    end

    def call
      app = App.find(id)
      Pundit.authorize(current_admin, app, :upgrade_dkim?)
      app.update_attributes!(legacy_dkim_selector: false)
      success!
      app
    end

    private

    attr_reader :current_admin, :id
  end
end
