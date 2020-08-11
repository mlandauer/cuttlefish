# frozen_string_literal: true

module AppServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:)
      super()
      @current_admin = current_admin
      @id = id
    end

    def call
      app = App.find(id)
      Pundit.authorize(current_admin, app, :destroy?)
      app.destroy
      success!
    end

    private

    attr_reader :current_admin, :id
  end
end
