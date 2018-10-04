# frozen_string_literal: true

class Mutations::RemoveBlockedAddress < Mutations::Base
  argument :id, ID, required: true, description: "The database ID of the blocked address you want to remove"

  field :blocked_address, Types::BlockedAddress, null: true, description: "Returns the blocked address it successfully removed. Returns null otherwise."

  def resolve(id:)
    destroy_blocked_address = DenyListServices::Destroy.call(id: id, current_admin: context[:current_admin])
    { blocked_address: destroy_blocked_address.result }
  end
end
