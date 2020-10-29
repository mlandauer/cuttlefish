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

  # Only allowed to register if you are the first admin
  def create?
    !Rails.configuration.cuttlefish_read_only_mode && Admin.first.nil?
  end
end
