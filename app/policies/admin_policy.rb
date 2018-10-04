# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  # This is currently unused
  def index?
    !user.nil?
  end

  def show?
    in_same_team?
  end

  def destroy?
    !Rails.configuration.cuttlefish_read_only_mode && in_same_team?
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

  private

  def in_same_team?
    user && user.team_id == record.team_id
  end
end
