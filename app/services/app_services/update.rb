# frozen_string_literal: true

module AppServices
  class Update < ApplicationService
    VALID_ATTRIBUTES = %i[
      name
      open_tracking_enabled
      click_tracking_enabled
      custom_tracking_domain
      from_domain
    ].freeze

    def initialize(
      current_admin:,
      id:,
      attributes:
    )
      @current_admin = current_admin
      @id = id
      @attributes = attributes.select { |k, _v| VALID_ATTRIBUTES.include?(k) }
    end

    def call
      app = App.find_by(id: id)
      if app.nil? || !AppPolicy.new(current_admin, app).update?
        fail! OpenStruct.new(
          type: :permission,
          message: "You don't have permissions to do this"
        )
        return
      end
      if app.update_attributes(attributes)
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

    attr_reader :current_admin, :id, :attributes
  end
end
