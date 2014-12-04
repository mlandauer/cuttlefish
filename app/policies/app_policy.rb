class AppPolicy < ApplicationPolicy
  def update?
    user.team_id == record.team_id && ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
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
    ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
