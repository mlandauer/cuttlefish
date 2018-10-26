# frozen_string_literal: true

module AdminServices
  class Destroy < ApplicationService
    def initialize(current_admin:, id:)
      @current_admin = current_admin
      @id = id
    end

    def call
      admin = Admin.find_by_id(id)
      if admin.nil?
        raise ActiveRecord::RecordNotFound
      elsif !AdminPolicy.new(current_admin, admin).destroy?
        raise Pundit::NotAuthorizedError
      else
        success!
        admin.destroy
      end
    end

    private

    attr_reader :id, :current_admin
  end
end
