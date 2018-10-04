# frozen_string_literal: true

module Types
  class BlockedAddress < GraphQL::Schema::Object
    field :id, ID, null: false, description: "The database ID"
    field :address, String, null: false, description: "Email address"
    field :because_of_delivery_event, Types::DeliveryEvent, null: true, description: "The delivery attempt that bounced that caused this address to be blocked"
    field :permissions, Types::BlockedAddressPermissions, null: false, description: "Permissions for current admin for accessing and editing this blocked address" do
      # Permissions should be always accessible even on apps that you can't show
      guard ->(_obj, _args, _ctx) { true }
    end

    def address
      object.address.text
    end

    def because_of_delivery_event
      object.caused_by_postfix_log_line
    end

    def permissions
      DenyListPolicy.new(context[:current_admin], object)
    end
  end
end
