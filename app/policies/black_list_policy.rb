class BlackListPolicy < ApplicationPolicy
  def destroy?
    user.team_id == record.team_id && !Rails.configuration.cuttlefish_read_only_mode
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
