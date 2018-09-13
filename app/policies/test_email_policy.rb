class TestEmailPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    user && !Rails.configuration.cuttlefish_read_only_mode
  end
end
