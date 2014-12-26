class AppPolicy < ApplicationPolicy
  def update?
    user.team_id == record.team_id && !Rails.configuration.cuttlefish_read_only_mode
  end

  def destroy?
    update?
  end

  def dkim?
    (user.super_admin? && record.cuttlefish? && !Rails.configuration.cuttlefish_read_only_mode) || update?
  end

  def toggle_dkim?
    dkim?
  end

  def create?
    !Rails.configuration.cuttlefish_read_only_mode
  end

  def show?
    user.super_admin? || super
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
