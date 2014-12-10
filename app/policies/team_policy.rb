class TeamPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def invite?
    user.super_admin? && !Rails.configuration.cuttlefish_read_only_mode
  end
end
