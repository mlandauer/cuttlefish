# frozen_string_literal: true

module AppServices
  class UpgradeDkim < ApplicationService
    def initialize(
      current_admin:,
      id:
    )
      @current_admin = current_admin
      @id = id
    end

    def call
      app = App.find(id)
      unless AppPolicy.new(current_admin, app).upgrade_dkim?
        raise Pundit::NotAuthorizedError
      end

      app.update_attributes!(legacy_dkim_selector: false)
      app
    end

    private

    attr_reader :current_admin, :id
  end
end
