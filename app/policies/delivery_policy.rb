class DeliveryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:email => :app).where("apps.team_id" => user.team_id)
    end
  end
end
