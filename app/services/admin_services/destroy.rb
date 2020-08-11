# frozen_string_literal: true

module AdminServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:)
      super()
      @current_admin = current_admin
      @id = id
    end

    def call
      admin = Admin.find(id)
      Pundit.authorize(current_admin, admin, :destroy?)
      admin.destroy
      success!
      admin
    end

    private

    attr_reader :id, :current_admin
  end
end
