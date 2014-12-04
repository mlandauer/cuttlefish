class TestEmailPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end
end
