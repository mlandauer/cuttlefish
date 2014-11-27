class AppPolicy < ApplicationPolicy
  def update?
    user.team_id == record.team_id
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
    true
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
