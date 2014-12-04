class TestEmailPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    ENV["CUTTLEFISH_READ_ONLY_MODE"].nil?
  end
end
