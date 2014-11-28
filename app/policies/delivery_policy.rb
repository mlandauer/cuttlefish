class DeliveryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Avoid using join here as it was a lot slower
      app_ids = AppPolicy::Scope.new(user, App).resolve.pluck(:id)
      scope.where(app_id: app_ids)
    end
  end
end
