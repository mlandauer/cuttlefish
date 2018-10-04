# frozen_string_literal: true

module DenyListServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:)
      @current_admin = current_admin
      @id = id
    end

    def call
      success!
      deny_list = DenyList.find_by_id(id)
      return if deny_list.nil?
      return unless DenyListPolicy.new(current_admin, deny_list).destroy?

      deny_list.destroy!
    end

    private

    attr_reader :id, :current_admin
  end
end
