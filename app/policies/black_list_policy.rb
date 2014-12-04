class BlackListPolicy < ApplicationPolicy
  def destroy?
    user.team_id == record.team_id && ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end

  class Scope < Scope
    def resolve
      scope.where(team_id: user.team_id)
    end
  end
end
