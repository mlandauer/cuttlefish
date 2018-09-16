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
    user && user.super_admin?
  end

  def invite?
    user && user.super_admin? && !Rails.configuration.cuttlefish_read_only_mode
  end

  # TODO: Add scope
end
