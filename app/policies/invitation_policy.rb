# frozen_string_literal: true

class InvitationPolicy < ApplicationPolicy
  def create?
    user && !Rails.configuration.cuttlefish_read_only_mode
  end

  def update?
    # We don't need to login to set the password and name for our own invitation
    # We're also passed an invitation_token which says who we are
    !Rails.configuration.cuttlefish_read_only_mode
  end
end
