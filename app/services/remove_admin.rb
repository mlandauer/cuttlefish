class RemoveAdmin < ApplicationService
  def initialize(current_admin:, id:)
    @current_admin = current_admin
    @id = id
  end

  def call
    admin = Admin.find(id)
    if AdminPolicy.new(current_admin, admin).destroy?
      success!
      admin.destroy
    else
      fail! "You don't have permission to remove this admin"
    end
  end

  private

  attr_reader :id, :current_admin
end
