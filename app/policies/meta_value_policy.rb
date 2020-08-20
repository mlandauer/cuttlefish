# frozen_string_literal: true

class MetaValuePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Avoid using join here as it was a lot slower
      app_ids = AppPolicy::Scope.new(user, App).resolve.pluck(:id)
      # But we're not completely avoiding joins here, so it will probably be quite slow
      scope.joins(:email).where(emails: { app_id: app_ids })
    end
  end
end
