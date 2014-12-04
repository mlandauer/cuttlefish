class TeamPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def invite?
    user.super_admin? && ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end
end
