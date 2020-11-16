# frozen_string_literal: true

class AddAddressIdIndexToDeliveries < ActiveRecord::Migration[4.2]
  def change
    add_index :deliveries, [:address_id, :created_at]
  end
end
