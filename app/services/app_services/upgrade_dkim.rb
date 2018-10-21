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
      app = App.find_by(id: id)
      if app.nil? || !AppPolicy.new(current_admin, app).upgrade_dkim?
        fail! OpenStruct.new(
          type: :permission,
          message: "You don't have permissions to do this"
        )
        return
      end
      success!

      app.update_attributes!(legacy_dkim_selector: false)
      app
    end

    private

    attr_reader :current_admin, :id
  end
end
