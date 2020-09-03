# frozen_string_literal: true

module DenyListServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:, app_id:)
      super()
      @current_admin = current_admin
      @id = id
      @app_id = app_id
    end

    def call
      deny_list = app_id ? AppDenyList.find(id) : DenyList.find(id)
      Pundit.authorize(current_admin, deny_list, :destroy?)
      deny_list.destroy!
      success!
      deny_list
    end

    private

    attr_reader :id, :app_id, :current_admin
  end
end
