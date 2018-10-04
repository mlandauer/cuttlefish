# frozen_string_literal: true

module Types
  class BlockedAddressConnection < Types::BaseConnection
    description "A list of blocked addresses"
    field :nodes, [Types::BlockedAddress],
          null: true,
          description: "A list of nodes"
  end
end
