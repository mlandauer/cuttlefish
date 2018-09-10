class AdminPolicy < ApplicationPolicy
  # This is currently unused
  def index?
    true
  end

  def show?
    in_same_team?
  end

  def destroy?
    !Rails.configuration.cuttlefish_read_only_mode &&
      in_same_team? &&
      user.id != record.id
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end

  private

  def in_same_team?
    user.team_id == record.team_id
  end
end
