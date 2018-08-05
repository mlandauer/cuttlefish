class AdminPolicy < ApplicationPolicy
  # This is currently unused
  def index?
    true
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
