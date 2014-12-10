class InvitationPolicy < ApplicationPolicy
  def create?
    !Rails.configuration.cuttlefish_read_only_mode
  end

  def update?
    create?
  end
end
