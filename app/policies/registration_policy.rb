class RegistrationPolicy < ApplicationPolicy
  def edit?
    ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def create?
    edit?
  end
end
