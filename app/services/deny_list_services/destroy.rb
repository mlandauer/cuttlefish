# frozen_string_literal: true

module DenyListServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:)
      super()
      @current_admin = current_admin
      @id = id
    end

    def call
      deny_list = AppDenyList.find(id)
      Pundit.authorize(current_admin, deny_list, :destroy?)
      deny_list.destroy!
      success!
      deny_list
    end

    private

    attr_reader :id, :current_admin
  end
end
