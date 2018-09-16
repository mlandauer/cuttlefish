class DenyListPolicy < ApplicationPolicy
  def destroy?
    user && user.team_id == record.team_id && !Rails.configuration.cuttlefish_read_only_mode
  end

  class Scope < Scope
    def resolve
      if user
        scope.where(team_id: user.team_id)
      else
        scope.none
      end
    end
  end
end
