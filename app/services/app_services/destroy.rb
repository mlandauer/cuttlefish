# frozen_string_literal: true

module AppServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:)
      @current_admin = current_admin
      @id = id
    end

    def call
      app = App.find_by(id: id)
      if app && AppPolicy.new(current_admin, app).destroy?
        success!
        app.destroy
      else
        fail! OpenStruct.new(
          type: :permission,
          message: "Couldn't remove app. You don't have the necessary permissions or the app with the given id doesn't exist."
        )
      end
    end

    private

    attr_reader :current_admin, :id
  end
end
