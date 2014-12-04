class InvitationPolicy < ApplicationPolicy
  def create?
    ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end
end
