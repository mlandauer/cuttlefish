# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  # This isn't currently used
  def show?
    user && user.team_id == record.id
  end

  # This isn't currently used
  def update?
    show?
  end

  def index?
    user&.site_admin?
  end

  def invite?
    user&.site_admin? && !Rails.configuration.cuttlefish_read_only_mode
  end

  class Scope < Scope
    def resolve
      if user&.site_admin?
        scope.all
      else
        # Perhaps this should return just your current team instead in
        # this case?
        scope.none
      end
    end
  end
end
