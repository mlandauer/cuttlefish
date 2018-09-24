class DestroyDenyList < ApplicationService
  def initialize(current_admin:, id:)
    @current_admin = current_admin
    @id = id
  end

  def call
    success!
    deny_list = DenyList.find_by_id(id)
    if deny_list && DenyListPolicy.new(current_admin, deny_list).destroy?
      deny_list.destroy!
    end
  end

  private

  attr_reader :id, :current_admin
end
