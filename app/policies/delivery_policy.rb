# frozen_string_literal: true

class DeliveryPolicy < ApplicationPolicy
  def show?
    if user&.site_admin?
      true
    else
      app_ids = AppPolicy::Scope.new(user, App).resolve.pluck(:id)
      app_ids.include?(record.app_id)
    end
  end

  def create?
    user && !Rails.configuration.cuttlefish_read_only_mode
  end

  class Scope < Scope
    def resolve
      # If the user is a super admin they should have access to all the emails
      # However, they aren't shown by default in the admin UI because it only
      # lists the apps that the admin is attached to. To see the emails for an
      # app belonging to another team, they need to navigate via the teams list.
      if user&.site_admin?
        scope
      else
        # Avoid using join here as it was a lot slower
        app_ids = AppPolicy::Scope.new(user, App).resolve.pluck(:id)
        scope.where(app_id: app_ids)
      end
    end
  end
end
