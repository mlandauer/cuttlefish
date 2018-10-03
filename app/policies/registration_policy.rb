# frozen_string_literal: true

class RegistrationPolicy < ApplicationPolicy
  def edit?
    !Rails.configuration.cuttlefish_read_only_mode
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
