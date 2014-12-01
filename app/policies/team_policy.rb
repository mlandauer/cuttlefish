class TeamPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def invite?
    index?
  end
end
