class AppPolicy < ApplicationPolicy
  def update?
    user.team_id == record.team_id && !Rails.configuration.cuttlefish_read_only_mode
  end

  def destroy?
    update?
  end

  def dkim?
    update?
  end

  def toggle_dkim?
    update?
  end

  def create?
    !Rails.configuration.cuttlefish_read_only_mode
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
