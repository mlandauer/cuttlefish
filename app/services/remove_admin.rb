class RemoveAdmin < ApplicationService
  def initialize(current_admin:, id:)
    @current_admin = current_admin
    @id = id
  end

  def call
    admin = Admin.find(id)
    if AdminPolicy.new(current_admin, admin).destroy?
      admin.destroy
      success!
    else
      fail!
    end
  end

  private

  attr_reader :id, :current_admin
end
