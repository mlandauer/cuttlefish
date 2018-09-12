class AppPolicy < ApplicationPolicy
  def update?
    user && user.team_id == record.team_id && !Rails.configuration.cuttlefish_read_only_mode
  end

  def destroy?
    update?
  end

  def dkim?
    (user && user.super_admin? && record.cuttlefish? && !Rails.configuration.cuttlefish_read_only_mode) || update?
  end

  # TODO: No reason for this to be seperate from dkim above
  def toggle_dkim?
    dkim?
  end

  def upgrade_dkim?
    dkim?
  end

  def create?
    user && !Rails.configuration.cuttlefish_read_only_mode
  end

  def show?
    (user && user.super_admin?) || super
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
