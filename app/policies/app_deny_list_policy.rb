# frozen_string_literal: true

class AppDenyListPolicy < ApplicationPolicy
  def destroy?
    app_ids = AppPolicy::Scope.new(user, App).resolve.pluck(:id)
    app_ids.include?(record.app_id) && !Rails.configuration.cuttlefish_read_only_mode
  end

  class Scope < Scope
    def resolve
      app_ids = AppPolicy::Scope.new(user, App).resolve.pluck(:id)
      scope.where(app_id: app_ids)
    end
  end
end
