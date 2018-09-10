class RemoveAdmin < ApplicationService
  def initialize(id:)
    @id = id
  end

  def call
    # TODO: Authorize
    Admin.find(id).destroy
  end

  private

  attr_reader :id
end
