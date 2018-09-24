class DestroyAdmin < ApplicationService
  def initialize(current_admin:, id:)
    @current_admin = current_admin
    @id = id
  end

  def call
    admin = Admin.find_by_id(id)
    if admin.nil? || !AdminPolicy.new(current_admin, admin).destroy?
      # Give a generic error message that covers "permissions" and "not found".
      # This is because we don't want clients to be able to distinguish these two
      # errors because it leaks information
      raise Failure, "You can't remove the admin with this id"
    end
    admin.destroy
  end

  private

  attr_reader :id, :current_admin
end
