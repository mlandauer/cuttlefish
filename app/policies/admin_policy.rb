class AdminPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
